extends TrashTool

@onready var trashRay := $trashRay
@onready var pickerAnim := $pickerAnim

@export var picker_range := 5.0

func primaryDown():
	pickerAnim.play("pick")
	
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
