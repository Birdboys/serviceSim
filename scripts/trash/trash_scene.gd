extends Node3D
class_name Trash

@export var interactBox : InteractBox
@export var trashBox : TrashBox
@export var trashMesh : MeshInstance3D


var type : TrashData.trash_types
var sub_type
var trash_name : String

func trashCollected():
	queue_free()

func loadTexture(skin):
	var new_texture = TrashData.getTexture(type, sub_type, skin)
	trashMesh.mesh.surface_get_material(0).albedo_texture = new_texture
