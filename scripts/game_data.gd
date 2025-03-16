extends Node

var total_trash_collected := 0
var total_money := 0

@onready var num_tool_slots := 2
@onready var unlocked_tools := ["basic_picker", "better_picker", "squeeze_picker", "auto_picker", "basic_vacuum", "spear_picker", "pogo_picker"]
@onready var current_gear := ["basic_picker", "", ""]
@onready var bag_dim :=  Vector2(8,8)
@onready var game_time := 1.0 #minutes
@onready var default_tool_data := {
	"basic_picker": {"price": 10, "owned": true, "trash":"11100"}, 
	"better_picker": {"price": 1, "owned": false, "trash":"11100"}, 
	"squeeze_picker": {"price": 1, "owned": false, "trash":"11110"}, 
	"auto_picker": {"price": 10, "owned": false, "trash": "11110"}, 
	"basic_vacuum": {"price": 5, "owned": false, "trash":"11110"}, 
	"spear_picker": {"price": 10, "owned": false, "trash":"11110"}, 
	"pogo_picker": {"price": 10, "owned": false, "trash":"11100"}
}

@onready var tool_data : Dictionary

func _ready() -> void:
	tool_data = default_tool_data.duplicate(true)

func weightedChoice():
	pass
