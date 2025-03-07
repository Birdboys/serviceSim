extends Node3D

@onready var townTiles := $townTiles
@onready var player := $playerCharacter

var block_size := Vector2(5, 5)
var block_overlap := 1
var game_tile_size := Vector2(100,100)
var wfc : BlockMS
var current_tile_pos := Vector2.ZERO
var prev_tile_pos := Vector2.ZERO
var current_block_pos := Vector2.ZERO
var prev_block_pos := Vector2.ZERO
var grid := {}
var adjacent_dirs := [Vector2(1,0), Vector2(1,1), Vector2(0,1), Vector2(-1,1), Vector2(-1,0), Vector2(-1,-1), Vector2(0,-1), Vector2(1,-1)]
var expand_thread : Thread
var start_time := -1
var total_time : float

const tile_to_scene := {
	WFCInfo.tile_type.GRASS: preload("res://scenes/tiles/grass_tile.tscn"),
	WFCInfo.tile_type.ROAD_L: preload("res://scenes/tiles/road_l_tile.tscn"),
	WFCInfo.tile_type.ROAD_X: preload("res://scenes/tiles/road_x_tile.tscn"),
	WFCInfo.tile_type.ROAD_E: preload("res://scenes/tiles/road_e_tile.tscn"),
	WFCInfo.tile_type.ROAD_R: preload("res://scenes/tiles/road_r_tile.tscn"),
	WFCInfo.tile_type.ROAD_T: preload("res://scenes/tiles/road_t_tile.tscn"),
	WFCInfo.tile_type.LAKE: preload("res://scenes/tiles/lake_tile.tscn"),
	WFCInfo.tile_type.PLAYGROUND: preload("res://scenes/tiles/playground_tile.tscn")
}

func _ready() -> void:
	total_time = floor(GameData.game_time * 60.0)
	#player.toggleReady(false)
	#player.UI.updateTimerLabel(total_time)
	wfc = BlockMS.new()
	wfc.initBlockMS(block_size, block_overlap)
	var init_time = Time.get_ticks_msec()
	await startGrid()
	await generateTiles()
	await startTrash()
	print("LOAD TIME: ", (Time.get_ticks_msec()-init_time)/1000.0)
	#player.loadTrashTools(GameStuff.current_gear)
	player.position += Vector3(1, 0, 1) * game_tile_size.x
	#bus.position += Vector3(1, 0, 1) * game_tile_size.x
	#var load_tween = get_tree().create_tween()
	#load_tween.tween_property($loadUI, "modulate", Color.TRANSPARENT, 0.5)
	#load_tween.tween_callback($loadUI.queue_free)
	#load_tween.tween_callback(player.toggleReady.bind(true))
	#load_tween.tween_interval(0.75)
	#load_tween.tween_property(bus, "global_position", bus.global_position - bus.basis.z * 40.0, 2.5)
	#load_tween.tween_callback(bus.queue_free)
	#$sunAnim.play("sun", -1, 0.2)
	start_time = Time.get_ticks_msec()
	
func _physics_process(delta: float) -> void:
	current_block_pos = posToBlock(player.position)    
	if current_block_pos != prev_block_pos:
		print("CHECKING EXPAND")
		prev_block_pos = current_block_pos
		checkExpandGrid()
	
	return
	current_tile_pos = posToTile(player.position)
	if current_tile_pos != prev_tile_pos:
		prev_tile_pos = current_tile_pos
		checkInitTrash()
	
	#if start_time > -1:
		#var elapsed_time = floor((Time.get_ticks_msec()-start_time)/1000.0)
		#player.UI.updateTimerLabel(total_time-elapsed_time)
		#if elapsed_time >= total_time and player.playing:
			#endGame()
	
func startGrid():
	var start_tile = WFCTile.new()
	start_tile.initPossibilities(["11"])
	start_tile.collapse()
	wfc.tile_grid[Vector2(1,1)] = start_tile
	wfc.setCurrentPosition(Vector2(0, 0))
	for dir in adjacent_dirs:
		await wfc.setCurrentPosition(dir)
		
func startTrash():
	return
	for x in range(-2, 3):
		for y in range(-2, 3):
			var trash_tile = Vector2(x, y)
			grid[trash_tile]['tile_scene'].initTrash()

func generateTiles():
	var generated = 0
	for t in wfc.tile_grid:
		if t in grid: 
			if grid[t]['tile_type'] == wfc.tile_grid[t].tile_type and grid[t]['tile_rot'] == wfc.tile_grid[t].rot_val:
				#print("TILE SKIPPED BECAUSE ITS THE SAME")
				continue
			else:
				grid[t]["tile_scene"].queue_free()
				grid.erase(t)
				#print("TILE UPDATED TO DIFFERENT TILE")
		grid[t] = {
			"tile_type": wfc.tile_grid[t].tile_type,
			"tile_rot": wfc.tile_grid[t].rot_val,
		}
		var new_tile = tile_to_scene[grid[t]["tile_type"]].instantiate()
		add_child(new_tile)
		new_tile.position = Vector3(game_tile_size.x * t.x, 0, game_tile_size.y * t.y)
		new_tile.rotation.y = -PI/2 * grid[t]["tile_rot"]
		grid[t]["tile_scene"] = new_tile
		generated += 1
		await get_tree().physics_frame
	print("NEW TILES GENERATED: ", generated)
	
func posToTile(pos: Vector3):
	var pos_2d = Vector2(pos.x, pos.z)# - game_tile_size/2
	var tile_pos = ((pos_2d + game_tile_size/2)/game_tile_size).floor()
	return tile_pos
	
func posToBlock(pos: Vector3):
	var pos_2d = Vector2(pos.x, pos.z)# - game_tile_size/2
	var tile_pos = ((pos_2d + game_tile_size/2)/game_tile_size).floor()
	var block_pos = (tile_pos/(block_size-Vector2.ONE)).floor()
	return block_pos

func checkExpandGrid():
	var current_time = Time.get_ticks_msec()
	var blocks_to_create = []
	for dir in adjacent_dirs:
		var new_block = dir + current_block_pos
		if new_block not in wfc.blocks:
			blocks_to_create.append(new_block)
	
	if len(blocks_to_create) > 0:
		await expandGrid(blocks_to_create)
		await generateTiles()
		
	print("TIME TO EXPAND: ", (Time.get_ticks_msec()-current_time)/1000.0)
	return

func checkInitTrash():
	for x in range(-2, 3):
		for y in range(-2, 3):
			var trash_tile = Vector2(x, y) + current_tile_pos
			if trash_tile in grid: grid[trash_tile]['tile_scene'].initTrash()
		
	
func expandGrid(blocks_to_create: Array):
	for b in blocks_to_create:
		await wfc.setCurrentPosition(b)
		await get_tree().physics_frame
		print("UPDATED A BLOCK")
	return

func loadTileThreaded(t: WFCInfo.tile_type, p, r):
	var new_tile = await tile_to_scene[t].instantiate()
	call_deferred("addTileThreaded", self, t, p, r)
	return new_tile
	
func addTileThreaded(thread:Thread, t, p, r):
	var new_tile = thread.wait_to_finish()
	add_child(new_tile)
	new_tile.position = Vector3(game_tile_size.x * t.x, 0, game_tile_size.y * t.y)
	new_tile.rotation.y = -PI/2 * grid[t]["tile_rot"]
	grid[t]["tile_scene"] = new_tile

func endGame():
	return
	#player.UI.updateTimerLabel(0)
	#player.toggleReady(false)
	#var end_tween = get_tree().create_tween()
	#end_tween.tween_property(endBG, "modulate", Color.WHITE, 0.5)
	#end_tween.tween_interval(0.5)
	#await end_tween.finished
	#GameStuff.total_money += player.current_trash_val
	#GameStuff.total_trash_collected += player.trash_collected
	#get_tree().change_scene_to_file("res://scenes/bed_menu.tscn")
	
