extends TrashToolBody

@onready var pickerMesh := $pickerMesh
@onready var litterArea := $litterArea
@onready var pickupArea := $pickupArea
@onready var pickerAnim := $pickerAnim
@export var collectable := false

var going := false
var throw_tween : Tween
var gravity := 10.0
var speed := 5.0
var throw_velocity := 7.5
var player 

func _ready() -> void:
	litterArea.area_entered.connect(collectTrash)
	pickupArea.body_entered.connect(pickupRobot)
	player = get_parent().get_parent().get_parent().get_parent()
	
func _process(delta: float) -> void:
	if going:
		if not is_on_floor(): velocity.y -= gravity * delta
		else:
			var lat_vel = Vector3(velocity.x, 0, velocity.z).normalized() * speed
			velocity.x = lat_vel.x
			velocity.z = lat_vel.z
		move_and_slide()
		
		if is_on_wall():
			velocity = get_wall_normal()
		
func primaryDown():
	if not going:
		going = true
		throwRobot()

func throwRobot():
	if throw_tween is Tween: throw_tween.kill()
	top_level = true
	velocity = -(player.transform.basis.z) * throw_velocity
	print(velocity)
	print("THROWN")
	pickerMesh.set_layer_mask_value(1, true)
	pickerMesh.set_layer_mask_value(2, false)
	litterArea.monitoring = true
	throw_tween = get_tree().create_tween()
	throw_tween.tween_property(self, "rotation", player.rotation + Vector3(0,deg_to_rad(-210),0), 0.2)
	throw_tween.tween_interval(0.5)
	throw_tween.tween_property(self, "collectable", true, 0.0)
	
func pickupRobot(b_): 
	if not collectable: return
	collectable = false
	going = false
	print("PICKED UP")
	top_level = false
	pickerAnim.play("RESET")
	pickerMesh.set_layer_mask_value(1, false)
	pickerMesh.set_layer_mask_value(2, true)

func collectTrash(t):
	if going and t is TrashBox and isTrashValid(t.get_parent()):
		emit_signal("attempt_collect_trash", t.get_parent())
