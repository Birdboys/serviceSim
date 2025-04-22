extends CharacterBody3D

@onready var neck := $playerNeck
@onready var cam := $playerNeck/playerCam
@onready var headAnim := $playerNeck/headAnim
@onready var toolCam := $toolLayer/toolCont/toolViewport/toolCam
@onready var toolHand := $playerNeck/playerCam/toolHand 
@onready var interactRay := $playerNeck/playerCam/interactRay
@onready var stateMachine := $stateMachine
@onready var UI := $playerUI
@onready var comboTimer := $comboTimer
@onready var callTimer := $callTimer
@onready var footstepRay := $footstepRay

var available_tools := []
var current_tool_id := -1
var current_tool 
var sensitivity := 0.0
var gravity = 10.0
var speed := 15.0
var shoes_mult := 2.0
var skates_mult := 3.0

var bag_dim := Vector2(8,16)
var trash_collected := 0
var value_collected := 0
var max_trash := 0
var combo_counter := 0
var max_combo := 0

var has_shoes := false
var has_skates := false
var has_cape := false
var active_robot = null

const combo_time_window := 3.0
const base_sens := 0.00005

signal called_home 

func _ready() -> void:
	has_cape = GameData.toy_data['cape']['owned']
	has_shoes = GameData.toy_data['running_shoes']['owned']
	has_skates = GameData.toy_data['roller_skates']['owned']
	
	if GameData.toy_data['infini_bag']['owned']: bag_dim.y *= 4
	stateMachine.initialize(self)
	max_trash = bag_dim.x * bag_dim.y
	comboTimer.timeout.connect(endCombo)
	callTimer.timeout.connect(calledHome)
	UI.initBag(bag_dim)
	UI.updateBagLabel(0, max_trash)
	updateSensitivity()
	#loadTrashTools(["basic_picker", "better_picker"])
	
func _process(delta: float) -> void:
	if stateMachine.current_state.movement_control: handleMovement(delta)
	if not headAnim.is_playing(): cam.position = cam.position.move_toward(Vector3.ZERO, delta)
	syncCameras()

func _physics_process(delta: float) -> void:
	if stateMachine.current_state.interact_control: handlePrompt()
	if not comboTimer.is_stopped() and combo_counter >= 3: UI.updateComboUI(comboTimer.time_left/combo_time_window)
	if not callTimer.is_stopped(): UI.updateCallUI((GameData.call_time-callTimer.time_left)/GameData.call_time)
	
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
		if event.is_action_pressed("call"): handleCall(true)
		if event.is_action_released("call"): handleCall(false)
		
func syncCameras():
	toolCam.global_transform = cam.global_transform
	
func handleCamera(event):
	if event is InputEventMouseButton or event is InputEventJoypadButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			rotate_y(-event.relative.x * sensitivity * base_sens)
			cam.rotate_x(-event.relative.y * sensitivity * base_sens)
			cam.rotation.x = clamp(cam.rotation.x, deg_to_rad(-70), deg_to_rad(85))

func handlePrompt():
	var interact_col = interactRay.get_collider()
	var interact_text = ""
	if interact_col and interact_col is InteractBox: interact_text = interact_col.getPrompt()
	UI.updatePrompt(interact_text)
	
func handleInteract():
	pass

func handleMovement(delta):
	var input_dir = Input.get_vector("left", "right", "forward", "back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed * stateMachine.current_state.speed_mult
		velocity.z = direction.z * speed * stateMachine.current_state.speed_mult
		if has_skates and Input.is_action_pressed("skate"):
			velocity.x *= skates_mult
			velocity.z *= skates_mult
		elif has_shoes and Input.is_action_pressed("sprint"):
			velocity.x *= shoes_mult
			velocity.z *= shoes_mult
	else:
		velocity.x = move_toward(velocity.x, 0.0, speed*10.0*delta)
		velocity.z = move_toward(velocity.z, 0.0, speed*10.0*delta)
	handleGravity(delta)
	move_and_slide()

func handleGravity(delta):
	velocity.y -= gravity * delta

func equipTool(tool_id):
	if tool_id > len(available_tools)-1: return
	if current_tool_id == tool_id:
		print("UNEQUIPPING")
		unequipTool()
		UI.hotbarSelect(-1)
		return
		
	unequipTool()
	UI.hotbarSelect(tool_id)
	current_tool = available_tools[tool_id].instantiate()
	current_tool_id = tool_id 
	toolHand.add_child(current_tool)
	current_tool.equip()
	current_tool.attempt_collect_trash.connect(collectTrash)
	
	match current_tool.tool_name:
		"pogo_picker":
			current_tool.pogo_jump.connect(pogoJump)
		"robot_picker":
			if active_robot:
				active_robot.queue_free()
				active_robot = null
			
func unequipTool():
	if current_tool: 
		match current_tool.tool_name:
			"pogo_picker":
				current_tool.pogo_jump.disconnect(pogoJump)
			"robot_picker":
				if current_tool.going:
					active_robot = current_tool
					current_tool.unequip()
					current_tool = null
					current_tool_id = -1
					return
				
		current_tool.unequip()
		current_tool.queue_free()
	current_tool = null
	current_tool_id = -1

func loadTrashTools(tools: Array):
	tools = tools.filter(func(t): return t != "")
	for t in tools:
		if t == "": continue
		available_tools.append(load("res://scenes/tools/%s.tscn" % t))
	if available_tools != []: 
		equipTool(0)
		UI.loadToolIcons(tools)

func collectTrash(t: Trash):
	if trash_collected >= max_trash: return
	var col_data = t.trashCollected()
	#var trash_val = col_data['value']
	#var trash_name = col_data['name']
	
	trash_collected +=  1
	value_collected += TrashData.getTrashPrice(t.type, t.sub_type)
	GameData.trash_data["total"] += 1
	match t.type:
		TrashData.trash_types.PAPER: GameData.trash_data['paper'] += 1
		TrashData.trash_types.PLASTIC: GameData.trash_data['plastic'] += 1
		TrashData.trash_types.METAL: GameData.trash_data['metal'] += 1
		TrashData.trash_types.GLASS: GameData.trash_data['glass'] += 1
		
	handleCombo()
	UI.addTrashToBag(t.trash_name, trash_collected)
	UI.updateBagLabel(trash_collected, max_trash)
	

func toggleUI(on: bool):
	UI.visible = on

func turnOn():
	stateMachine.on_state_transition(stateMachine.current_state, "walkState")
	
func turnOff():
	stateMachine.on_state_transition(stateMachine.current_state, "offState")

func updateSensitivity():
	sensitivity = GameData.settings_data['sensitivity']

func updateFOV():
	cam.fov = GameData.settings_data['fov']

func handleCombo():
	combo_counter += 1
	if combo_counter > max_combo: max_combo = combo_counter
	comboTimer.start(combo_time_window)
	UI.setComboLabel(combo_counter)

func endCombo():
	combo_counter = 0
	UI.updateComboUI(0)
	UI.setComboLabel(0)

func handleCall(start: bool):
	if start:
		callTimer.start(GameData.call_time)
	else:
		callTimer.stop()
		UI.updateCallUI(0)

func calledHome():
	emit_signal("called_home")
	
func pogoJump(v):
	velocity.y = v
	handleFootstep()

func handleFootstep():
	if not footstepRay.is_colliding(): return
	var floor = footstepRay.get_collider()
	if floor is not StaticBody3D: return
	
	if floor.get_collision_layer_value(10): #grass
		AudioHandler.playSound("footstep_grass")
	elif floor.get_collision_layer_value(11): #pavement
		AudioHandler.playSound("footstep_pavement")
	elif floor.get_collision_layer_value(12): #rocks
		AudioHandler.playSound("footstep_rocks")
	elif floor.get_collision_layer_value(13): #water
		AudioHandler.playSound("footstep_water")
	elif floor.get_collision_layer_value(14): #metal
		AudioHandler.playSound("footstep_metal")
	elif floor.get_collision_layer_value(15): #bush
		AudioHandler.playSound("footstep_bush")
	
