extends CharacterBody3D

@onready var neck := $playerNeck
@onready var cam := $playerNeck/playerCam
@onready var interactRay := $playerNeck/playerCam/interactRay
@onready var trashHand := $playerNeck/playerCam/trashHand
@onready var stateMachine := $stateMachine
@onready var UI := $playerUI

var sensitivity := 0.0015
var gravity = 10.0
var speed := 75.0

func _ready() -> void:
	stateMachine.initialize(self)
	UI.initBag(Vector2(4,4))
func _process(delta: float) -> void:
	if stateMachine.current_state.movement_control: handleMovement(delta)

func _physics_process(delta: float) -> void:
	if stateMachine.current_state.interact_control: handlePrompt()
	
func _unhandled_input(event: InputEvent) -> void:
	if stateMachine.current_state.camera_control: handleCamera(event)
	if stateMachine.current_state.interact_control: 
		if event.is_action_pressed("interact"): handleInteract()
		if event.is_action_pressed("hotbar"):
			var hb_key = int(OS.get_keycode_string(event.keycode))-1
			equipTool(hb_key)
	
func handleCamera(event):
	if event is InputEventMouseButton or event is InputEventJoypadButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			rotate_y(-event.relative.x * sensitivity)
			cam.rotate_x(-event.relative.y * sensitivity)
			cam.rotation.x = clamp(cam.rotation.x, deg_to_rad(-60), deg_to_rad(85))

func handlePrompt():
	var interact_col = interactRay.get_collider()
	var interact_text = ""
	if interact_col: interact_text = interact_col.getPrompt()
	UI.updatePrompt(interact_text)
	
func handleInteract():
	pass

func handleMovement(delta):
	var input_dir = Input.get_vector("left", "right", "forward", "back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed * stateMachine.current_state.speed_mult
		velocity.z = direction.z * speed * stateMachine.current_state.speed_mult
	else:
		velocity.x = move_toward(velocity.x, 0, speed*10.0*delta)
		velocity.z = move_toward(velocity.z, 0, speed*10.0*delta)
	handleGravity(delta)
	move_and_slide()

func handleGravity(delta):
	velocity.y -= gravity * delta

func equipTool(hotbar_id):
	pass
