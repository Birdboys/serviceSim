extends Node
class_name WFCInfo

enum tile_type {GRASS, ROAD_L, ROAD_X, ROAD_E, ROAD_T, ROAD_R, LAKE, PLAYGROUND}
enum connector_type {SIDEWALK, ROAD, GRASS}

const tile_weights := {tile_type.GRASS:5.0, tile_type.LAKE:2.0, tile_type.PLAYGROUND:0.75}
const tile_to_scene := {
	tile_type.GRASS: "grass",
	tile_type.ROAD_L: "road_l",
	tile_type.ROAD_X: "road_x",
	tile_type.ROAD_E: "road_e",
	tile_type.ROAD_R: "road_r",
	tile_type.ROAD_T: "road_t",
	tile_type.LAKE: "lake",
	tile_type.PLAYGROUND: "playground"
}
const dir_to_num := {Vector2.UP:0,Vector2.RIGHT:1,Vector2.DOWN:2,Vector2.LEFT:3}
