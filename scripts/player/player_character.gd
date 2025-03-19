extends CharacterBody3D

@onready var neck := $playerNeck
@onready var cam := $playerNeck/playerCam
@onready var toolCam := $toolLayer/toolCont/toolViewport/toolCam
@onready var toolHand := $playerNeck/playerCam/toolHand 
@onready var interactRay := $playerNeck/playerCam/interactRay
@onready var stateMachine := $stateMachine
@onready var UI := $playerUI
var available_tools := []
var current_tool_id := -1
var current_tool 
var sensitivity := 0.0015
var gravity = 10.0
var speed := 15.0

var bag_dim := Vector2(8,8)
var trash_collected := 0
var value_collected := 0
var max_trash := 0

func _ready() -> void:
	stateMachine.initialize(self)
	max_trash = bag_dim.x * bag_dim.y
	UI.initBag(bag_dim)
	UI.updateBagLabel(0, max_trash)
	loadTrashTools(["basic_picker", "better_picker"])
	
func _process(delta: float) -> void:
	if stateMachine.current_state.movement_control: handleMovement(delta)
	syncCameras()

func _physics_process(delta: float) -> void:
	if stateMachine.current_state.interact_control: handlePrompt()
	
func _unhandled_input(event: InputEvent) -> void:
	if stateMachine.current_state.camera_control: handleCamera(event)
	if stateMachine.current_state.interact_control: 
		if event.is_action_pressed("interact"): handleInteract()
		if event.is_action_pressed("hotbar"):
			var hb_key = int(OS.get_keycode_string(event.keycode))-1
			equipTool(hb_key)
		if event.is_action_pressed("tool_primary") and current_tool: current_tool.primaryDown()
		if event.is_action_released("tool_primary") and current_tool: current_tool.primaryUp()
		if event.is_action_pressed("tool_secondary") and current_tool: current_tool.secondaryDown()
		if event.is_action_released("tool_secondary") and current_tool: current_tool.secondaryUp()

func syncCameras():
	toolCam.global_transform = cam.global_transform
	
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

func equipTool(tool_id):
	if tool_id > len(available_tools)-1: return
	if current_tool_id == tool_id:
		print("UNEQUIPPING")
		unequipTool()
		#UI.hotbarSelect(-1)
		return
		
	unequipTool()
	#UI.hotbarSelect(tool_idx)
	current_tool = available_tools[tool_id].instantiate()
	current_tool_id = tool_id 
	toolHand.add_child(current_tool)
	current_tool.equip()
	current_tool.attempt_collect_trash.connect(collectTrash)
	

func unequipTool():
	if current_tool: 
		current_tool.unequip()
		current_tool.queue_free()
	current_tool = null
	current_tool_id = -1

func loadTrashTools(tools: Array):
	for t in tools:
		if t == "": continue
		available_tools.append(load("res://scenes/tools/%s.tscn" % t))
	if available_tools != []: 
		equipTool(0)
		#UI.loadToolIcons(tools)

func collectTrash(t: Trash):
	if trash_collected >= max_trash: return
	var col_data = t.trashCollected()
	#var trash_val = col_data['value']
	#var trash_name = col_data['name']
	
	trash_collected += 1
	#value_collected += trash_val
	UI.addTrashToBag(t.trash_name, trash_collected)
	UI.updateBagLabel(trash_collected, max_trash)
