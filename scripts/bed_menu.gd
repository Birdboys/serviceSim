extends Node3D

@onready var UI := $UILayer
@onready var playerCam := $playerCam
@onready var tools := $toolBenchMesh/tools
@onready var cams := {
	"bed": $bedCam,	
	"table": $tableCam,
	"trash": $trashCam,
	"computer": $computerCam,
	"door": $doorCam,
	"tool_mag": $tableMesh/toolMagCam,
	"toy_mag": $tableMesh/toyMagCam,
	"poster": $posterCam,
}
@onready var areas := {
	"table": $tableMesh/tableArea,
	"trash": $trashMesh/trashArea,
	"computer": $computerMesh/computerArea,
	"door": $toolArea,
	"tool_mag": $tableMesh/toolMagArea,
	"toy_mag": $tableMesh/toyMagArea,
	"poster": $posterMesh/posterArea,
}
@onready var escape_path := {
	"bed": "",	
	"table": "bed",
	"trash": "bed",
	"computer": "bed",
	"door": "bed",
	"tool_mag": "table",
	"toy_mag": "table",
	"poster": "bed",
}
@onready var door := $door
@onready var doorArea := $doorArea
@onready var doorAnim := $door/doorAnim
@onready var leaveLabel := $doorArea/leaveLabel
@onready var transitionUI := $transitionLayer/endBG
var can_leave := false
var can_click := false
var current_menu := "bed"
var transition_tween : Tween
var cam_tween_time := 0.8

func _ready() -> void:
	for a in areas:
		areas[a].input_event.connect(menuClick.bind(a))
	for t in tools.get_children():
		t.input_event.connect(toolClick.bind(t.name))
	getOwnedTools()
	UI.menus['door'].ready_to_leave.connect(toggleReady)
	UI.menus['tool_mag'].tool_purchased.connect(getOwnedTools)
	doorArea.mouse_entered.connect(toggleDoor.bind(true))
	doorArea.mouse_exited.connect(toggleDoor.bind(false))
	doorArea.input_event.connect(tryToLeave)
	doorArea.monitoring = false
	can_click = true
	toggleToolCols(false)
	UI.reset()
	
	var load_tween := get_tree().create_tween()
	load_tween.tween_property(transitionUI, "modulate", Color.TRANSPARENT, 1.0)
	load_tween.tween_callback(transitionUI.queue_free)
	await load_tween.finished
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("escape") and current_menu != "bed" and can_click:
		UI.escLabel.visible = false
		can_click = false
		leaveMenu(current_menu)
		current_menu = escape_path[current_menu]
		UI.reset()
		transitionCamera(current_menu) 
		

func menuClick(cam, event:InputEvent, _event_pos, _event_norm, _shape_idx, m):
	if event is InputEventMouseButton and event.pressed and event.button_index == 1 and can_click:
		if m == current_menu: return
		can_click = false
		UI.reset()
		leaveMenu(current_menu)
		current_menu = m
		transitionCamera(current_menu)

func toolClick(cam, event:InputEvent, _event_pos, _event_norm, _shape_idx, t):
	if event is InputEventMouseButton and event.pressed and event.button_index == 1 and current_menu == "door":
		UI.toolClicked(t)
	
func transitionCamera(m):
	if transition_tween is Tween and transition_tween.is_running(): transition_tween.kill()
	print("TRANSITIONING TO ", m)
	var transition_tween := get_tree().create_tween().set_parallel(true).set_ease(Tween.EASE_IN_OUT)
	print("MADE TWEEN")
	print(cams[m].global_rotation)
	transition_tween.tween_property(playerCam, "position", cams[m].global_position, cam_tween_time)
	transition_tween.tween_property(playerCam, "rotation", cams[m].global_rotation, cam_tween_time)
	transition_tween.tween_property(playerCam, "fov", cams[m].fov, cam_tween_time)
	transition_tween.tween_callback(loadMenu.bind(m)).set_delay(cam_tween_time)
	print("TWEEN FINISHED")

func leaveMenu(m):
	match m:
		"door":
			toggleToolCols(false)
			can_leave = false
			var door_tween = get_tree().create_tween().tween_property(door, "rotation", Vector3.ZERO, 0.5)
			leaveLabel.visible = false
			doorArea.visible = false
			areas["door"].visible = true
		"table":
			areas["tool_mag"].visible = false
			areas["toy_mag"].visible = false
			areas["table"].visible = true
		"tool_mag":
			areas["tool_mag"].visible = true
			UI.menus[m].resetMiddle()
		"toy_mag":
			areas["toy_mag"].visible = true
			UI.menus[m].resetMiddle()
		"computer":
			UI.menus[m].computerAnim.play_backwards("turn_computer_on")
			
func loadMenu(m):
	print("TRANSITION FINISHED")
	can_click = true
	match m:
		"door": 
			toggleToolCols(true)
			doorArea.visible = true
			areas["door"].visible = false
			leaveLabel.visible = true
		"table":
			areas["tool_mag"].visible = true
			areas["toy_mag"].visible = true
			areas["table"].visible = false
		"tool_mag":
			areas["table"].visible = false
			areas["tool_mag"].visible = false
			areas["toy_mag"].visible = false
		"toy_mag":
			areas["table"].visible = false
			areas["tool_mag"].visible = false
			areas["toy_mag"].visible = false
		#"computer":
			#UI.menus[m].computerAnim.play("turn_computer_on")

	UI.loadMenu(m)
	
func toggleToolCols(on: bool):
	for t in tools.get_children():
		if on: t.activate()
		else: t.deactivate()
		#t.visible = on

func toggleDoor(on: bool):
	if current_menu != "door": return
	if not GameData.current_gear.any(func(t): return t != ""): return
	if on: doorAnim.play("open_door")
	else: doorAnim.play_backwards("open_door")

func toggleReady(yes: bool):
	can_leave = yes

func tryToLeave(cam, event:InputEvent, _event_pos, _event_norm, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == 1 and can_leave:
		can_leave = false
		GameData.saveGame()
		get_tree().change_scene_to_file("res://scenes/litter_picking_level.tscn")

func getOwnedTools():
	for t in GameData.tool_data:
		if tools.find_child(t): tools.find_child(t).visible = GameData.tool_data[t]['owned']
