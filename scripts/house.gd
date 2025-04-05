extends Node3D

@onready var houseNode := $houseNode

func _ready() -> void:
	var house_type := randi_range(1, 6)
	var house_texture := randi_range(0, 9)
	
	var houseMesh = GameData.house_meshes[house_type].instantiate()
	houseNode.add_child(houseMesh)
	#houseMesh.mesh = GameData.house_meshes[house_type]
	houseMesh.mesh.surface_get_material(0).albedo_texture = GameData.house_textures[house_texture]
	houseNode.scale.x = -1 if randf() > 0.5 else 1
