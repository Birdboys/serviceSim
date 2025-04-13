extends Node3D

@export var surface_shape := Vector3(1, 1, 1)
@export var lake_trash := false
@export var tree_trash := false
@export var num_trash := 5
@export var trash_dist := {
	TrashData.trash_types.PAPER: 1.0,
	TrashData.trash_types.PLASTIC: 1.0,
	TrashData.trash_types.METAL: 1.0,
	TrashData.trash_types.GLASS: 1.0,
}
	
func initTrash():
	for x in range(num_trash):
		var trash_type = TrashData.getWeightedChoice(trash_dist)
		var trash_skin = TrashData.getWeightedSkin()
		var new_trash = TrashData.getTrash(trash_type)
		var new_trash_pos = getTrashPoint()
		add_child(new_trash)
		new_trash.initializeTrash(trash_skin)
		new_trash.position = new_trash_pos
		new_trash.rotation = new_trash_pos.normalized() + Vector3((randf()-0.5)*PI/20.0, randf() * 2 * PI, (randf()-0.5)*PI/20.0)

		if x % 5 == 0: await get_tree().physics_frame
	return

func weightedTrashChoice():
	var new_trash_type = randf() * trash_dist.values().reduce(func(x, acc): return acc+x,0)
	var weight_acc := 0.0
	for t in trash_dist:
		weight_acc += trash_dist[t]
		if new_trash_type <= weight_acc:
			return t

func getTrashPoint():
	var radius := Vector3.FORWARD
	radius = radius.rotated(Vector3.RIGHT, randf_range(-PI, PI))
	radius = radius.rotated(Vector3.UP, randf_range(-PI, PI))
	radius = radius * surface_shape
	return radius
