extends TrashTool
class_name LitterPicker
@onready var trashRay := $trashRay
@onready var pickerAnim := $pickerAnim

@export var picker_range := 5.0

func _ready() -> void:
	upgrade()
	
func primaryDown():
	pickerAnim.play("pick", -1, speed_mod)
	
func equip():
	trashRay.target_position = Vector3(0,0,-picker_range)
	
func trashRayCollect():
	trashRay.force_raycast_update()
	if not trashRay.is_colliding(): return
	var new_trash = trashRay.get_collider().get_parent()
	if new_trash is Trash and isTrashValid(new_trash):
		AudioHandler.playSound3D("%s_pickup" % [TrashData.trash_type_names[new_trash.type]], new_trash.global_position)
		emit_signal("attempt_collect_trash", new_trash)
	else:
		AudioHandler.playSound3D("%s_reject" % [TrashData.trash_type_names[new_trash.type]], new_trash.global_position)

func upgrade():
	var upgrade_level = GameData.tool_data[tool_name]['upgrade']
	if upgrade_level == 0: return
	
	match tool_name:
		"basic_picker":
			pass
		"better_picker":
			picker_range += upgrade_level * 0.25
		"claw_picker":
			speed_mod *= 1 + upgrade_level * 0.1
		"auto_picker":
			picker_range += upgrade_level * 0.25
