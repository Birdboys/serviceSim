extends Control

@onready var bedMenu := preload('res://scenes/bed_menu.tscn')
var playing := false

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.keycode != KEY_ESCAPE and event.keycode != KEY_ALT and event.keycode != KEY_TAB and not playing:
		playing = true
		get_tree().change_scene_to_packed(bedMenu)
