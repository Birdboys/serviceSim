class_name ModelSynthesizer

var rules_path := "res://rules.txt" 
var tiles_path := "res://tiles.txt"

var rules : Array[String] = []
var all_tile_types : Array[String] = []
var grid_size : Vector2
var grid : Dictionary
var last_collapsed := Vector2(-1,0)

func getInfo():
	getTileInfo()
	getRulesInfo()
	
func initModelSynthesis(size):
	grid_size = size
	initTiles(grid_size)

func doModelSynthesis():
	for y in range(grid_size.y):
		for x in range(grid_size.x):
			var next_coord = Vector2(x, y)
			#if not grid[next_coord].is_collapsed:
			grid[next_coord].collapseWeighted()
			populate(next_coord)
			#populateRec(next_coord)
	return grid

func doOneRound():
	if not checkAllCollapsed(): 
		var new_coord = last_collapsed + Vector2.RIGHT
		if new_coord.x == grid_size.x:
			new_coord = Vector2(0, new_coord.y+1)
		grid[new_coord].collapse()            
		populate(new_coord)
		last_collapsed = new_coord
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
					#restart()
					pass
					
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
						#restart()
						pass

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
	initModelSynthesis(grid_size)
	doModelSynthesis()

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
			if len(grid[Vector2(x, y)].all_possibilities) > 1:
				row.append(len(grid[Vector2(x, y)].all_possibilities))
			else:
				row.append(grid[Vector2(x, y)].all_possibilities[0])
		print(row)
	print("\n")
