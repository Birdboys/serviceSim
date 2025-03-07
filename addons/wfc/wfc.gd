class_name WaveFunctionCollapser

var rules_path := "res://rules.txt" 
var tiles_path := "res://tiles.txt"

var rules : Array[String] = []
var all_tile_types : Array[String] = []
var grid_size : Vector2
var grid : Dictionary

func getInfo():
	getTileInfo()
	getRulesInfo()
	
func initWaveFunctionCollapse(size):
	grid_size = size
	initTiles(grid_size)

func doWaveFunctionCollapse():
	while not checkAllCollapsed():
		var lowest_entropy_coord = getLowEntropyTile()
		grid[lowest_entropy_coord].collapseWeighted()
		populate(lowest_entropy_coord)
		#populateRec(lowest_entropy_coord)
	return grid

func doOneRound():
	if not checkAllCollapsed(): 
		var lowest_entropy_coord = getLowEntropyTile()
		grid[lowest_entropy_coord].collapseWeighted()            
		populate(lowest_entropy_coord)
	return grid
	
func getTileInfo():
	var tiles_file_text := FileAccess.get_file_as_string(tiles_path)
	var all_tiles = tiles_file_text.split("\n").slice(0, -1)
	for t in all_tiles: 
		all_tile_types.append(t)
	
func getRulesInfo():
	var rules_file_text := FileAccess.get_file_as_string(rules_path)
	var all_rules = rules_file_text.split("\n").slice(0, -1)
	for r in all_rules:
		rules.append(r)
		
func initTiles(size: Vector2):
	grid_size = size
	for x in range(grid_size.x):
		for y in range(grid_size.y):
			var new_tile = WFCTile.new()
			new_tile.initPossibilities(all_tile_types)
			grid[Vector2(x, y)] = new_tile

func checkAllCollapsed():
	return not grid.values().any(func(tile:WFCTile): return not tile.is_collapsed)

func getLowEntropyTile():
	var lowest_entropy = INF
	var lowest_entropy_tiles : Array[Vector2] = []
	for c in grid:
		if grid[c].is_collapsed: continue
		#var tile_entropy = grid[c].getEntropy()
		var tile_entropy = grid[c].getShannonEntropy()
		if tile_entropy < lowest_entropy: #NEEDS > 0 FOR NORMAL ENTROPY
			lowest_entropy = tile_entropy
			lowest_entropy_tiles = [c]
		if tile_entropy == lowest_entropy:
			lowest_entropy_tiles.append(c)
	return lowest_entropy_tiles.pick_random()

func populate(tile_coord: Vector2):
	var cur_coords = tile_coord
	var curr_possibilities = grid[cur_coords].all_possibilities.duplicate(true)

	for dir in getValidDirections(cur_coords):
		var neighbor_coords = cur_coords + dir
		var neighbor_possibilities = grid[neighbor_coords].all_possibilities.duplicate(true)
		
		
		if len(neighbor_possibilities) == 0: continue
		
		for n_possibility in neighbor_possibilities:
			var is_possible = curr_possibilities.any(func(t_possibility): return checkNeighborRule(t_possibility, n_possibility, dir))
			if not is_possible:
				grid[neighbor_coords].constrain(n_possibility)
				if grid[neighbor_coords].all_possibilities == []:
					pass
					#restart()
		#printGrid()
		
func populateRec(tile_coord: Vector2):
	var stack = [tile_coord]
	while len(stack) > 0:
		var cur_coords = stack.pop_back()
		for dir in getValidDirections(cur_coords):
			var neighbor_coords = cur_coords + dir
			var neighbor_possibilities = grid[neighbor_coords].all_possibilities.duplicate(true)
			var curr_possibilities = grid[cur_coords].all_possibilities.duplicate(true)
			
			if len(neighbor_possibilities) == 0: 
				continue
				
			for n_possibility in neighbor_possibilities:
				var is_possible = curr_possibilities.any(func(t_possibility): return checkNeighborRule(t_possibility, n_possibility, dir))
				if not is_possible:
					grid[neighbor_coords].constrain(n_possibility)
					if neighbor_coords not in stack:
						stack.append(neighbor_coords)
					if grid[neighbor_coords].all_possibilities == []:
						pass
						#restart()

func getValidDirections(coord: Vector2):
	var valid_directions = []
	if coord.x-1 >= 0: valid_directions.append(Vector2.LEFT)
	if coord.x+1 < grid_size.x: valid_directions.append(Vector2.RIGHT)
	if coord.y-1 >= 0: valid_directions.append(Vector2.UP)
	if coord.y+1 < grid_size.y: valid_directions.append(Vector2.DOWN)
	return valid_directions

func checkNeighborRule(t, n, d):
	var r = "%s, %s, %s" % [t,n,WFCInfo.dir_to_num[d]]
	return r in rules

func restart():
	#initWaveFunctionCollapse(grid_size)
	print("RESTARTED")
	doWaveFunctionCollapse()

func putBlockToGrid(block:Dictionary, offset:Vector2):
	grid = {}
	for coord in block:
		grid[coord+offset] = block[coord]
		
	for t in grid:
		if grid[t].is_collapsed:
			populate(t)
	return
		
func printGrid():
	for y in range(grid_size.y):
		var row = []
		for x in range(grid_size.x):
			row.append(grid[Vector2(x, y)].is_collapsed)
		print(row)
	print("\n")
