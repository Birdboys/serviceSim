extends Node

const save_data_path := "user://service_sim_save_data.json"
const tool_mag_data := {
	"left1A": null,
	"left1B": null,
	"right1A": "basic_picker",
	"right1B": "better_picker",
	"left2A": "claw_picker",
	"left2B": "auto_picker",
	"right2A": "extendo_picker",
	"right2B": "spear_picker",
	"left3A": "pogo_picker",
	"left3B": "net_picker",
	"right3A": "vacuum_picker",
	"right3B": "robot_picker",
}

const toy_mag_data := {
	"left1A": null,
	"left1B": null,
	"right1A": "running_shoes",
	"right1B": "floaties",
	"left2A": "cape",
	"left2B": "utility_belt",
	"right2A": "watch",
	"right2B": "roller_skates",
	"left3A": "walkman",
	"left3B": "infini_bag",
	"right3A": "action_figure",
	"right3B": "action_figure",
	"left4A": "action_figure_a",
	"left4B": "action_figure_b",
	"right4A": "action_figure_g",
	"right4B": "action_figure_o",
}
var total_trash_collected := 0
var total_money := 1000

@onready var current_gear := ["basic_picker", "robot_picker"]
@onready var bag_dim :=  Vector2(8,8)
@onready var game_time := 2.5 * 60.0 #seconds
@onready var call_time := 3.0
@onready var default_tool_data := {
	"basic_picker": {"price": 0, "upgrade_price":0, "owned": true, "upgrade": 5, "name":"Basic Picker"}, 
	"better_picker": {"price": 50, "upgrade_price":10, "owned": false, "upgrade": 0, "name":"Better Picker"}, 
	"claw_picker": {"price": 75, "upgrade_price":15, "owned": false, "upgrade": 0, "name":"Claw Picker"}, 
	"auto_picker": {"price": 100, "upgrade_price":15, "owned": false, "upgrade": 0, "name":"Auto-Picker"}, 
	"extendo_picker": {"price": 150, "upgrade_price":15, "owned":false, "upgrade":0, "name":"Extendo-Picker"},
	"spear_picker": {"price": 150, "upgrade_price":15, "owned":false, "upgrade":0, "name":"Spear Picker"},
	"pogo_picker": {"price": 150, "upgrade_price":15, "owned":false, "upgrade":0, "name":"Pogo-Picker"},
	"net_picker": {"price": 150, "upgrade_price":15, "owned":false, "upgrade":0, "name":"Net Picker"},
	"vacuum_picker": {"price": 150, "upgrade_price":15, "owned":false, "upgrade":0, "name":"Vacuum Picker"},
	"robot_picker": {"price": 150, "upgrade_price":15, "owned":false, "upgrade":0, "name":"Robot Picker"},
}

@onready var default_toy_data := {
	"floaties": {"owned":true, "price":100, "name":"Floaties"},
	"walkman": {"owned":false, "price":100, "name":"Walkman"},
	"running_shoes": {"owned":false, "price":100, "name":"Running Shoes"},
	"roller_skates": {"owned":false, "price":100, "name":"Roller Skates"},
	"cape": {"owned":false, "price":100, "name":"Super Cape"},
	"watch": {"owned":false, "price":100, "name":"Watch"},
	"utility_belt": {"owned":false, "price":100, "name":"Utility Belt"},
	"infini_bag": {"owned":false, "price":100, "name":"Semi-Infini-Bag"},
	"action_figure": {"owned":false, "price":100, "name":"Action Figure"},
	"action_figure_a": {"owned":false, "price":100, "name":"Action Figure ALPHA"},
	"action_figure_b": {"owned":false, "price":100, "name":"Action Figure BETA"},
	"action_figure_g": {"owned":false, "price":100, "name":"Action Figure GAMMA"},
	"action_figure_o": {"owned":false, "price":100, "name":"Action Figure OMEGA"},
}

@onready var default_settings_data := {
	"sound": 0.5,
	"music": 0.0,
	"sensitivity": 25.0,
	"fov": 65.0
}

@onready var default_trash_data := {
	"paper": 0,
	"plastic": 0,
	"metal": 0,
	"glass": 0,
	"total": 0,
}

@onready var house_meshes : Dictionary
@onready var house_textures : Dictionary
@onready var car_meshes := [preload("res://scenes/houses/car_pb.tscn"), preload("res://scenes/houses/car_truck.tscn"), preload("res://scenes/houses/car_minivan.tscn"), preload("res://scenes/houses/car_muscle.tscn")]
@onready var car_textures : Array
@onready var tool_data : Dictionary
@onready var toy_data : Dictionary
@onready var settings_data : Dictionary
@onready var trash_data : Dictionary

@onready var tree := preload("res://scenes/houses/tree.tscn")

func _ready() -> void:
	#if FileAccess.file_exists(save_data_path): 
		#print("SAVE FILE EXISTS")
		#loadSaveData()
	#else: 
		#print("NO SAVE FILE EXISTS")
		#createSaveData()
	loadDefaults()
	loadHouseData()
	loadCarData()

func loadDefaults():
	tool_data = default_tool_data.duplicate(true)
	toy_data = default_toy_data.duplicate(true)
	settings_data = default_settings_data.duplicate(true)
	trash_data = default_trash_data.duplicate(true)
	
func loadHouseData():
	for x in range(1,7):
		house_meshes[x] = load("res://scenes/houses/house_%s.tscn" % x)
	for x in range(0,10):
		house_textures[x] = load("res://assets/textures/houses/house_%s.png" % x)

func loadCarData():
	for x in range(0,10):
		car_textures.append(load("res://assets/textures/cars/car_%s.png" % x))
		
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
	toy_data = parsed_save_data['toy_data']
	settings_data = parsed_save_data['settings_data']
	trash_data = parsed_save_data['trash_data']

	
func saveGame():
	var new_save_data = {}
	new_save_data['total_trash_collected'] = total_trash_collected
	new_save_data['total_money'] = total_money
	new_save_data['current_gear'] = current_gear
	new_save_data['bag_dim_x'] = bag_dim.x
	new_save_data['bag_dim_y'] = bag_dim.y
	new_save_data['tool_data'] = tool_data
	new_save_data['toy_data'] = toy_data
	new_save_data['settings_data'] = settings_data
	new_save_data['trash_data'] = trash_data
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
