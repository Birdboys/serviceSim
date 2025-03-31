extends Node

const tool_mag_data := {
	"left1A": "basic_picker",
	"left1B": "better_picker",
	"right1A": "claw_picker",
	"right1B": "auto_picker",
}

var total_trash_collected := 0
var total_money := 500

@onready var num_tool_slots := 2
@onready var unlocked_tools := ["basic_picker", "better_picker", "squeeze_picker", "auto_picker", "basic_vacuum", "spear_picker", "pogo_picker"]
@onready var current_gear := ["basic_picker", ""]
@onready var bag_dim :=  Vector2(8,8)
@onready var game_time := .25 * 60.0 #seconds
@onready var default_tool_data := {
	"basic_picker": {"price": 0, "upgrade_price":0, "owned": true, "upgrade": 5}, 
	"better_picker": {"price": 50, "upgrade_price":10, "owned": false, "upgrade": 0}, 
	"claw_picker": {"price": 75, "upgrade_price":15, "owned": false, "upgrade": 0}, 
	"auto_picker": {"price": 100, "upgrade_price":15, "owned": false, "upgrade": 0}, 
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

@onready var tool_data : Dictionary
@onready var settings_data : Dictionary

func _ready() -> void:
	tool_data = default_tool_data.duplicate(true)
	settings_data = default_settings_data.duplicate(true)

func saveGame():
	pass
