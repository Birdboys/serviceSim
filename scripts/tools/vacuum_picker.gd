extends TrashTool

@onready var pickerMesh := $pickerMesh
@onready var vacuumArea := $vacuumArea
@onready var litterArea := $litterArea
@onready var suckSound := $suckSound

var sucked_trash := []
var sucking := false
var suck_power := 7.5

func _ready() -> void:
	vacuumArea.area_entered.connect(addTrash)
	vacuumArea.area_exited.connect(removeTrash)
	litterArea.area_entered.connect(collectTrash)
	upgrade()
	
func _process(delta: float) -> void:
	if sucking:
		for t in sucked_trash:
			var dir = t.global_position.direction_to(global_position)
			var suck_dir = Vector3(dir.x, 0, dir.z)
			t.global_position += suck_dir * suck_power * delta
			if t.global_position.y > 0.05:
				t.global_position.y -= 10.0 * delta
		

func primaryDown():
	sucking = true
	suckSound.play()
	
func primaryUp():
	sucking = false
	suckSound.stop()
	
func addTrash(t):
	if t is TrashBox and isTrashValid(t.get_parent()):
		sucked_trash.append(t.get_parent())
	print(sucked_trash)
	
func removeTrash(t):
	if t is TrashBox and isTrashValid(t.get_parent()):
		print("REMOVING TRASH")
		sucked_trash.erase(t.get_parent())
	print(sucked_trash)

func collectTrash(t):
	if sucking and t is TrashBox and isTrashValid(t.get_parent()):
		emit_signal("attempt_collect_trash", t.get_parent())
		sucked_trash.erase(t.get_parent())
		AudioHandler.playSound("%s_pickup" % [TrashData.trash_type_names[t.get_parent().type]])

func upgrade():
	vacuumArea.scale = Vector3.ONE * (1+0.2 * GameData.tool_data[tool_name]['upgrade'])
	suck_power *= 1+0.2 * GameData.tool_data[tool_name]['upgrade']
