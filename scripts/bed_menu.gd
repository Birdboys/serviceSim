extends Node3D

@onready var UI := $UILayer
@onready var playerCam := $playerCam
@onready var tools := $toolBenchMesh/tools
@onready var cams := {
	"bed": $bedCam,	
	"table": $tableCam,
	"trash": $trashCam,
	"computer": $computerCam,
	"door": $doorCam
}
@onready var areas := {
	"table": $tableMesh/tableArea,
	"trash": $trashMesh/trashArea,
	"computer": $computerMesh/computerArea,
	"door": $toolArea
}
@onready var door := $door
@onready var doorArea := $doorArea
@onready var doorAnim := $door/doorAnim

var can_click := false
var current_menu := "main"
var transition_tween : Tween

func _ready() -> void:
	for a in areas:
		areas[a].input_event.connect(menuClick.bind(a))
	for t in tools.get_children():
		t.input_event.connect(toolClick.bind(t.name))
	doorArea.mouse_entered.connect(toggleDoor.bind(true))
	doorArea.mouse_exited.connect(toggleDoor.bind(false))
	doorArea.monitoring = false
	can_click = true
	toggleToolCols(false)
	UI.reset()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("escape") and current_menu != "bed" and can_click:
		if current_menu == "door": 
			var door_tween = get_tree().create_tween().tween_property(door, "rotation", Vector3.ZERO, 0.5)
		can_click = false
		current_menu = "bed"
		UI.reset()
		transitionCamera("bed") 
		

func menuClick(cam, event:InputEvent, _event_pos, _event_norm, _shape_idx, m):
	if event is InputEventMouseButton and event.pressed and event.button_index == 1 and can_click:
		if m == current_menu: return
		can_click = false
		UI.reset()
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
	transition_tween.tween_property(playerCam, "position", cams[m].position, 1.0)
	transition_tween.tween_property(playerCam, "rotation", cams[m].rotation, 1.0)
	transition_tween.tween_property(playerCam, "fov", cams[m].fov, 1.0)
	transition_tween.tween_callback(loadMenu.bind(m)).set_delay(1.0)
	print("TWEEN FINISHED")

func loadMenu(m):
	print("TRANSITION FINISHED")
	can_click = true
	match m:
		"door": 
			toggleToolCols(true)
			doorArea.monitoring = true
		_: 
			toggleToolCols(false)
			doorArea.monitoring = true
	UI.loadMenu(m)
	
func toggleToolCols(on: bool):
	for t in tools.get_children():
		if on: t.activate()
		else: t.deactivate()

func toggleDoor(on: bool):
	if current_menu != "door": return
	print(GameData.current_gear, GameData.current_gear.any(func(t): return t != ""))
	if not GameData.current_gear.any(func(t): return t != ""): return
	if on: doorAnim.play("open_door")
	else: doorAnim.play_backwards("open_door")
