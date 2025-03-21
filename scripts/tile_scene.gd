extends Node3D
class_name TileScene

@onready var trashScatterer := $trashScatterer
@export var auto_rotate := false
var scattered := false


func _ready() -> void:
	if auto_rotate:
		rotation.y = PI/2.0 * randi_range(0,3)
		
func initTrash():
	if scattered: return
	scattered = true
	await trashScatterer.initTrash()
