extends Node3D
class_name Trash

@export var interactBox : InteractBox
@export var trashBox : TrashBox
@export var trashMesh : MeshInstance3D

var is_lake_trash := false
var is_tree_trash := false
var type : TrashData.trash_types
var sub_type 
var skin_type : int
var trash_name : String


func trashCollected():
	queue_free()

func initializeTrash(skin):
	skin_type = skin
	var new_texture = TrashData.getTexture(type, sub_type, skin)
	trashMesh.mesh.surface_get_material(0).albedo_texture = new_texture
	trash_name = TrashData.getTrashName(type, sub_type, skin)
