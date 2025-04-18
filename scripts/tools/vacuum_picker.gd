extends TrashTool

@onready var pickerMesh := $pickerMesh
@onready var vacuumArea := $vacuumArea
@onready var litterArea := $litterArea

var sucked_trash := []
var sucking := false
var suck_power := 7.5

func _ready() -> void:
	vacuumArea.area_entered.connect(addTrash)
	vacuumArea.area_exited.connect(removeTrash)
	litterArea.area_entered.connect(collectTrash)
	
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

func primaryUp():
	sucking = false

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
