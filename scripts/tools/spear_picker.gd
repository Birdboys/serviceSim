extends TrashToolBody

enum spear_state {IDLE, READY, FLYING, THROWN, RETURNING}

var throw_velocity := 40.0
var gravity := 10.0

@onready var pickerAnim := $pickerAnim
@onready var litterArea := $pickerMesh/litterArea
@onready var pickerMesh := $pickerMesh
@onready var trashPos := $trashPos
@export var state := spear_state.IDLE

var held_trash := []

func _ready() -> void:
	upgrade()
	litterArea.area_entered.connect(collectTrash)
	
func _process(delta: float) -> void:
	match state:
		spear_state.FLYING:
			velocity.y -= gravity * delta
			move_and_slide()
			rotation.x += PI/10.0 * delta
			
			if get_slide_collision_count() > 0:
				state = spear_state.THROWN
				litterArea.monitoring = false
				velocity = Vector3.ZERO
				return
		
		spear_state.THROWN:
			velocity.y -= gravity * delta
			move_and_slide()
			if Vector2(global_position.x, global_position.z).distance_to(Vector2(get_parent().global_position.x, get_parent().global_position.z)) < 2.0:
				pickupSpear()
			
		spear_state.RETURNING:
			if not is_on_floor():
				velocity.y -= gravity * delta
			move_and_slide()
			
			var ret_dir = global_position.direction_to(get_parent().global_position) * 20.0 * delta
			global_position += Vector3(ret_dir.x, 0, ret_dir.z)
			if Vector2(global_position.x, global_position.z).distance_to(Vector2(get_parent().global_position.x, get_parent().global_position.z)) < 2.0:
				pickupSpear()
				
func primaryDown():
	match state:
		spear_state.IDLE:
			pickerAnim.play("charge")

func primaryUp():
	match state:
		spear_state.IDLE:
			pickerAnim.play_backwards("charge")
		spear_state.READY:
			throwSpear()
			
func secondaryDown():
	match state:
		spear_state.THROWN:
			state = spear_state.RETURNING

func secondaryUp():
	match state:
		spear_state.RETURNING:
			state = spear_state.THROWN
			
func throwSpear():
	state = spear_state.FLYING
	top_level = true
	velocity = -transform.basis.y * throw_velocity
	pickerMesh.set_layer_mask_value(1, true)
	pickerMesh.set_layer_mask_value(2, false)
	litterArea.monitoring = true

func pickupSpear():
	top_level = false
	if len(held_trash) > 0:
		for t in held_trash:
			AudioHandler.playSound("%s_pickup" % [TrashData.trash_type_names[t.type]])
			t.reparent(get_tree().root)
			t.global_position.y = 0.0
			held_trash.erase(t)
			emit_signal("attempt_collect_trash", t)
			held_trash.erase(t)
			
	litterArea.monitoring = false
	pickerAnim.play("RESET")
	pickerMesh.set_layer_mask_value(1, false)
	pickerMesh.set_layer_mask_value(2, true)
	
func collectTrash(t):
	print("TRYING TO COLLECT TRASH")
	if t is TrashBox and isTrashValid(t.get_parent()) and t.get_parent() not in held_trash:
		held_trash.append(t.get_parent())
		var new_trash = t.get_parent()
		new_trash.reparent(trashPos)
		#new_trash.position = new_trash.position.normalized() * 0.2

func upgrade():
	throw_velocity += 1.0 * GameData.tool_data[tool_name]['upgrade']
