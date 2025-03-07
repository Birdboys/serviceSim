extends Resource
class_name WFCTileDesc

@export var tile_type : WFCInfo.tile_type
@export var rot_vals : Array[int]

@export var top_connectors : Array[WFCInfo.connector_type]
@export var bottom_connectors : Array[WFCInfo.connector_type]
@export var left_connectors : Array[WFCInfo.connector_type]
@export var right_connectors : Array[WFCInfo.connector_type]

@export var top_illegal_tiles : Array[WFCInfo.tile_type]
@export var bottom_illegal_tiles : Array[WFCInfo.tile_type]
@export var left_illegal_tiles : Array[WFCInfo.tile_type]
@export var right_illegal_tiles : Array[WFCInfo.tile_type]

func getRotatedConnectors(tile_rot, neighbor_dir):
	var rotated_neighbor_dir = neighbor_dir.rotated(-tile_rot * PI/2.0).round()
	match rotated_neighbor_dir:
		Vector2.UP: return top_connectors
		Vector2.DOWN: return bottom_connectors
		Vector2.LEFT: return left_connectors
		Vector2.RIGHT: return right_connectors

func getIllegalNeighbors(tile_rot, neighbor_dir):
	var rotated_neighbor_dir = neighbor_dir.rotated(-tile_rot * PI/2.0).round()
	match rotated_neighbor_dir:
		Vector2.UP: return top_illegal_tiles
		Vector2.DOWN: return bottom_illegal_tiles
		Vector2.LEFT: return left_illegal_tiles
		Vector2.RIGHT: return right_illegal_tiles
