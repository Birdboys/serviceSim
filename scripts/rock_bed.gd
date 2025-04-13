extends Node3D

@onready var trees := $trees
@onready var stones := $stones

	
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

func doStones():
	for stone in stones.get_children():
		if randf() < 0.75:
			stone.queue_free()
		else:
			stone.rotation.y = randf_range(0, PI)
			stone.scale = Vector3.ONE * randf_range(0.75, 1.25)
		#await get_tree().process_frame
	stones.visible = true
