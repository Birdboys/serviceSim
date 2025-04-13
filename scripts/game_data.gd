extends Node

const save_data_path := "user://service_sim_save_data.json"
const tool_mag_data := {
	"left1A": "basic_picker",
	"left1B": "better_picker",
	"right1A": "claw_picker",
	"right1B": "auto_picker",
}

var total_trash_collected := 0
var total_money := 300

@onready var current_gear := ["basic_picker", ""]
@onready var bag_dim :=  Vector2(8,8)
@onready var game_time := 2.5 * 60.0 #seconds
@onready var call_time := 3.0
@onready var default_tool_data := {
	"basic_picker": {"price": 0, "upgrade_price":0, "owned": true, "upgrade": 5, "name":"Basic Picker"}, 
	"better_picker": {"price": 50, "upgrade_price":10, "owned": false, "upgrade": 0, "name":"Better Picker"}, 
	"claw_picker": {"price": 75, "upgrade_price":15, "owned": false, "upgrade": 0, "name":"Claw Picker"}, 
	"auto_picker": {"price": 100, "upgrade_price":15, "owned": false, "upgrade": 0, "name":"Auto-Picker"}, 
	#"basic_vacuum": {"price": 5, "owned": false, "trash":"11110"}, 
	#"spear_picker": {"price": 10, "owned": false, "trash":"11110"}, 
	#"pogo_picker": {"price": 10, "owned": false, "trash":"11100"}
}

@onready var default_settings_data := {
	"sound": 0.5,
	"music": 0.0,
	"sensitivity": 25.0,
	"fov": 65.0
}

@onready var house_meshes : Dictionary
@onready var house_textures : Dictionary
@onready var tool_data : Dictionary
@onready var settings_data : Dictionary

@onready var tree := preload("res://scenes/houses/tree.tscn")

func _ready() -> void:
	if FileAccess.file_exists(save_data_path): 
		print("SAVE FILE EXISTS")
		loadSaveData()
	else: 
		print("NO SAVE FILE EXISTS")
		createSaveData()
	loadHouseData()

func loadDefaults():
	tool_data = default_tool_data.duplicate(true)
	settings_data = default_settings_data.duplicate(true)
	
func loadHouseData():
	for x in range(1,7):
		house_meshes[x] = load("res://scenes/houses/house_%s.tscn" % x)
	for x in range(0,10):
		house_textures[x] = load("res://assets/textures/houses/house_%s.png" % x)

func createSaveData():
	loadDefaults()
	saveGame()

func loadSaveData():
	var save_file = FileAccess.open(save_data_path, FileAccess.READ)
	var parsed_save_data = JSON.parse_string(save_file.get_as_text())
	total_trash_collected = parsed_save_data['total_trash_collected']
	total_money = parsed_save_data['total_money']
	current_gear = parsed_save_data['current_gear']
	bag_dim.x = parsed_save_data['bag_dim_x']
	bag_dim.y = parsed_save_data['bag_dim_y']
	tool_data = parsed_save_data['tool_data']
	settings_data = parsed_save_data['settings_data']

	
func saveGame():
	var new_save_data = {}
	new_save_data['total_trash_collected'] = total_trash_collected
	new_save_data['total_money'] = total_money
	new_save_data['current_gear'] = current_gear
	new_save_data['bag_dim_x'] = bag_dim.x
	new_save_data['bag_dim_y'] = bag_dim.y
	new_save_data['tool_data'] = tool_data
	new_save_data['settings_data'] = settings_data
	var json_save_data = JSON.stringify(new_save_data)
	
	var save_file = FileAccess.open(save_data_path, FileAccess.WRITE)
	save_file.store_line(json_save_data)
	save_file.close()
	print("GAME SAVED")

func resetSaveData():
	if not FileAccess.file_exists(save_data_path): return
	DirAccess.remove_absolute(save_data_path)
	total_money = 0
	total_trash_collected = 0
	current_gear = ["basic_picker", ""]
	createSaveData()
	return
