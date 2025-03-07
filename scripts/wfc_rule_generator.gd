extends Node

var tile_desc_path := "res://addons/wfc/tile_descriptions/"
var tile_types_path := "res://tiles.txt"
var rules_file_path := "res://rules.txt"
var tile_descriptions : Array[WFCTileDesc]
var tile_rules : Array[String]
var tile_types : Array[String]

func _ready() -> void:
	loadDescriptions()
	getWFCInformation()
	saveRules()
	saveTiles()
	print("RULES DONE")
	get_tree().create_timer(0.25).timeout.connect(get_tree().quit)
	
func loadDescriptions():
	var desc_dir = DirAccess.open(tile_desc_path)
	for file in desc_dir.get_files():
		var new_desc = ResourceLoader.load(tile_desc_path+file)
		tile_descriptions.append(new_desc)

func getWFCInformation():
	for original_tile in tile_descriptions:
		for og_tile_rot in original_tile.rot_vals:
			tile_types.append("%s%s" % [original_tile.tile_type, og_tile_rot])
			for neighbor_tile in tile_descriptions:
				for nb_tile_rot in neighbor_tile.rot_vals:
					for neighbor_dir in WFCInfo.dir_to_num.keys():
						if checkNeighborConnection(original_tile,og_tile_rot,neighbor_tile,nb_tile_rot,neighbor_dir):
							var new_rule = "%s%s, %s%s, %s" % [
								original_tile.tile_type,
								og_tile_rot,
								neighbor_tile.tile_type,
								nb_tile_rot,
								WFCInfo.dir_to_num[neighbor_dir]
							]
							tile_rules.append(new_rule)

func saveRules():
	var rules_file := FileAccess.open(rules_file_path, FileAccess.WRITE)
	for rule in tile_rules:
		rules_file.store_line(rule)
	rules_file.close()
	
func saveTiles():
	var tiles_file := FileAccess.open(tile_types_path, FileAccess.WRITE)
	for t in tile_types:
		tiles_file.store_line(t)
	tiles_file.close()
		
func checkNeighborConnection(t:WFCTileDesc, t_r:int, n:WFCTileDesc, n_r:int, d:Vector2):
	if n.tile_type in t.getIllegalNeighbors(t_r, d):
		print("%s rot %s cant be next to %s in %s dir" % [t.tile_type, t_r, n.tile_type, d])
		return false
	
	var t_conns = t.getRotatedConnectors(t_r, d)
	var n_conns = n.getRotatedConnectors(n_r, -d)
	for conn in n_conns:
		if conn in t_conns:
			return true
	return false
