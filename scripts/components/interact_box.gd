extends Area3D
class_name InteractBox

@export_multiline var object_prompt : String
@export var interact_ret : String
@export var interactable := true
@export var on_start := true
@export var interactCol : CollisionShape3D

signal interacted
# Called when the node enters the scene tree for the first time.
func _ready():
	if on_start:
		activate()
	else:
		deactivate()

func getPrompt():
	return object_prompt

func interact():
	if interactable:
		emit_signal("interacted")
		return interact_ret

func activate():
	interactable = true
	monitoring = true
	monitorable = true
	
func deactivate():
	interactable = false
	monitoring = true
	monitorable = true
