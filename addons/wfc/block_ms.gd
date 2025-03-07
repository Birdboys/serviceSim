class_name BlockMS

var ms : ModelSynthesizer
var block_dim : Vector2
var block_overlap : int
var current_pos := Vector2.ZERO
var tile_grid := {}
var blocks : Array[Vector2]

func initBlockMS(dim, ov:=1):
	block_dim = dim
	block_overlap = ov
	ms = ModelSynthesizer.new()
	ms.getInfo()
	ms.initModelSynthesis(dim + Vector2.ONE * 2)
	
func initBlock(block_coord: Vector2):
	blocks.append(block_coord)
	for x in range(block_dim.x):
		for y in range(block_dim.y):
			var tile_coord = Vector2(x, y) + block_coord * (block_dim - Vector2.ONE * block_overlap)
			if tile_coord not in tile_grid:
				var new_tile = WFCTile.new()
				tile_grid[tile_coord] = new_tile
				new_tile.initPossibilities(ms.all_tile_types)
	
func collapseBlock(block_coord: Vector2):
	var b = getExtendedBlock(block_coord)
	var offset = b.keys()[0]
	await ms.putBlockToGrid(b, -offset)
	#ms.printGrid()
	var collapsed_block = await ms.doModelSynthesis()
	for t in collapsed_block:
		var tile_coord = (t-Vector2.ONE) + block_coord * (block_dim - Vector2.ONE * block_overlap)
		if tile_coord in tile_grid:
			tile_grid[tile_coord] = collapsed_block[t]
		#if tile_coord.x >= 0 and tile_coord.x < block_dim.x and tile_coord.y >= 0 and tile_coord.y < block_dim.y:
			#tile_grid[tile_coord] = collapsed_block[t]

func getBlock(block_coord: Vector2):
	var b = {}
	for x in range(block_dim.x):
		for y in range(block_dim.y):
			var tile_coord = Vector2(x, y) + block_coord * (block_dim - Vector2.ONE * block_overlap)
			b[tile_coord] = tile_grid[tile_coord]
	return b

func getExtendedBlock(block_coord: Vector2):
	var b = {}
	for x in range(-1, block_dim.x+1):
		for y in range(-1, block_dim.y+1):
			var tile_coord = Vector2(x, y) + block_coord * (block_dim - Vector2.ONE * block_overlap)
			#starting exemption
			if tile_coord == Vector2(1,1) and tile_coord in tile_grid:
				b[tile_coord + Vector2.ONE] = tile_grid[tile_coord]
				continue
				
			#block on extended border
			if x == -1 or y == -1 or x == block_dim.x or y == block_dim.y:
				if tile_coord in tile_grid:
					b[tile_coord + Vector2.ONE] = tile_grid[tile_coord]
				else:
					var new_tile = WFCTile.new()
					new_tile.initPossibilities(["00"])
					new_tile.collapse()
					b[tile_coord + Vector2.ONE] = new_tile
			
			#other blocks
			else:
				var new_tile = WFCTile.new()
				new_tile.initPossibilities(ms.all_tile_types)
				b[tile_coord + Vector2.ONE] = new_tile
				
	return b

func moveCurrentPosition(dir:Vector2):
	current_pos += dir
	if current_pos not in blocks:
		await initBlock(current_pos)
		await collapseBlock(current_pos)

func setCurrentPosition(pos:Vector2):
	current_pos = pos
	if current_pos not in blocks:
		await initBlock(current_pos)
		await collapseBlock(current_pos)
