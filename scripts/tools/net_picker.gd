extends TrashTool

@onready var pickerAnim := $pickerAnim
@onready var pickerMesh := $pickerMesh
@onready var litterArea := $litterArea

func _ready() -> void:
	upgrade()
	
func primaryDown():
	pickerAnim.play("pick")
	
func collectTrash():
	print(litterArea.get_overlapping_areas())
	for b in litterArea.get_overlapping_areas():
		if b is TrashBox and isTrashValid(b.get_parent()):
			emit_signal("attempt_collect_trash", b.get_parent())

func upgrade():
	litterArea.scale = Vector3.ONE * (1+0.2 * GameData.tool_data[tool_name]['upgrade'])
