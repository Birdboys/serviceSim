extends LitterPicker

@onready var bodyMesh := $auto_picker
@onready var pickerMesh := $auto_picker/auto_bottom
var reset_tween : Tween
var ready_tween : Tween
	
func primaryDown():
	if reset_tween is Tween and reset_tween.is_running(): reset_tween.kill()
	pickerAnim.play("ready", -1, speed_mod)

func primaryUp():
	print("STOPPING")
	pickerAnim.stop(true)
	resetTween()
	
func resetTween():
	if reset_tween is Tween and reset_tween.is_running(): reset_tween.kill()
	reset_tween = get_tree().create_tween().set_parallel(true)
	reset_tween.tween_property(bodyMesh, "rotation", Vector3(deg_to_rad(-3.9),deg_to_rad(-75.1),deg_to_rad(-10.1)), 0.5)
	reset_tween.tween_property(bodyMesh, "position", Vector3(1.184,0.658,-0.795), 0.5)
	reset_tween.tween_property(pickerMesh, "position", Vector3(0,-0.95,0), 0.2)

func startAutoPick():
	pickerAnim.play("pick")
