extends TrashTool

@onready var pickerAnim := $pickerAnim
@onready var pickerMesh := $pickerMesh
@onready var litterArea := $litterArea

func primaryDown():
	pickerAnim.play("pick")
	
func collectTrash():
	print(litterArea.get_overlapping_areas())
	for b in litterArea.get_overlapping_areas():
		if b is TrashBox and isTrashValid(b.get_parent()):
			emit_signal("attempt_collect_trash", b.get_parent())
