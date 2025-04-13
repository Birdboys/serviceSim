extends Node3D

@onready var houseNode := $houseNode
@onready var trees := $trees

func randomizeHouse():
	var house_type := randi_range(1, 6)
	var house_texture := randi_range(0, 9)
	
	var houseMesh = GameData.house_meshes[house_type].instantiate()
	houseNode.add_child(houseMesh)
	houseMesh.mesh.surface_get_material(0).albedo_texture = GameData.house_textures[house_texture]
	houseNode.scale.x = -1 if randf() > 0.5 else 1
	doTrees()
	
func doTrees():
	for tree in trees.get_children():
		if randf() < 0.4:
			var new_tree = GameData.tree.instantiate()
			tree.add_child(new_tree)
			new_tree.randomizeTree()
		else:
			tree.queue_free()
		#await get_tree().process_frame
	trees.visible = true
