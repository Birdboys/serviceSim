extends Node3D

@export var valid_rects : Array[Rect2i]
@export var invalid_rects : Array[Rect2i]
@export var num_trash := 25
@export var miss_chances := 15

func initTrash():
	return
	#for x in range(num_trash):
		#var trash_type = ['tall_can', 'wine_bottle', "wide_can"].pick_random()
		#var new_trash = TrashInfo.trash_to_scene[trash_type].instantiate()
		#var new_trash_rect = valid_rects.pick_random()
		#var rect_beginning = new_trash_rect.position
		#var rect_end = new_trash_rect.end
		#var new_trash_pos = Vector2()
		##print(get_parent(), " ", get_parent().name, " ", valid_rects)
		#new_trash_pos.x = randf_range(rect_beginning.x,rect_end.x)
		#new_trash_pos.y = randf_range(rect_beginning.y,rect_end.y)
		#
		#while miss_chances > 0:
			#for rect in invalid_rects:
				#if rect.has_point(new_trash_pos):
					#miss_chances -= 1
					#new_trash_pos.x = randf_range(rect_beginning.x,rect_end.x)
					#new_trash_pos.y = randf_range(rect_beginning.y,rect_end.y)
					##print("MISS")
					#continue
			#break
		#add_child(new_trash)
		#new_trash.getSubType(trash_type)
		#new_trash.position = Vector3(new_trash_pos.x, 0, new_trash_pos.y)
		#if x % 5 == 0: await get_tree().physics_frame
	#return
