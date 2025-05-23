extends Node3D

@export var lake_trash := false
@export var tree_trash := false
@export var valid_rects : Array[Rect2]
@export var invalid_rects : Array[Rect2]
@export var num_trash := 25
@export var miss_chances := 15
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
		var new_trash_rect = valid_rects.pick_random()
		var rect_beginning = new_trash_rect.position
		var rect_end = new_trash_rect.end
		var new_trash_pos = Vector2()
		var placed = false
		new_trash_pos.x = randf_range(rect_beginning.x,rect_end.x)
		new_trash_pos.y = randf_range(rect_beginning.y,rect_end.y)
		while not placed:
			placed = true
			new_trash_pos.x = randf_range(rect_beginning.x,rect_end.x)
			new_trash_pos.y = randf_range(rect_beginning.y,rect_end.y)
			if miss_chances == 0:
				placed = false
				break
			for rect in invalid_rects:
				if rect.has_point(new_trash_pos):
					miss_chances -= 1
					new_trash_pos.x = randf_range(rect_beginning.x,rect_end.x)
					new_trash_pos.y = randf_range(rect_beginning.y,rect_end.y)
					placed = false
					continue
					
		if not placed: continue
		add_child(new_trash)
		new_trash.initializeTrash(trash_skin)
		new_trash.position = Vector3(new_trash_pos.x, randf() * -0.05, new_trash_pos.y)
		new_trash.rotation = Vector3((randf()-0.5)*PI/20.0, randf() * 2 * PI, (randf()-0.5)*PI/20.0)

		if x % 5 == 0: await get_tree().physics_frame
	return

func weightedTrashChoice():
	var new_trash_type = randf() * trash_dist.values().reduce(func(x, acc): return acc+x,0)
	var weight_acc := 0.0
	for t in trash_dist:
		weight_acc += trash_dist[t]
		if new_trash_type <= weight_acc:
			return t
