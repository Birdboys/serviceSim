extends Node3D

@onready var trees := $trees
@onready var stones := $stones

	
func doTrees():
	for tree in trees.get_children():
		if randf() < 0.4:
			tree.randomizeTree()
		else:
			tree.clearTree()
		#await get_tree().process_frame
	trees.visible = true

func doStones():
	for stone in stones.get_children():
		if randf() < 0.75:
			stone.queue_free()
		else:
			stone.rotation.y = randf_range(0, PI)
		#await get_tree().process_frame
	stones.visible = true
