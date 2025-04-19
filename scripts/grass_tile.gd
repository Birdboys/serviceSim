extends Node3D

@onready var trashScatterer := $trashScatterer
@onready var trees := $trees

var scattered := false

func initTrash():
	if scattered: return
	scattered = true
	await doTrees()
	trashScatterer.initTrash()

func doTrees():
	for x in randi_range(40, 60):
		var new_tree = GameData.tree.instantiate()
		trees.add_child(new_tree)
		new_tree.position = Vector3(randi_range(-50,50), 0,randi_range(-50,50))
		new_tree.randomizeTree()
		if x % 5 == 0: await get_tree().process_frame
