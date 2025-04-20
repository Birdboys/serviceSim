extends Node3D

@onready var toolSpot := $toolSpot
@onready var toolCam := $toolCam

var tool_path := "res://assets/toy_meshes/"
var og_cam_pos := Vector3(0.0, 1.75, 3.5)

#tool spot rotation Vector3(-15, 30, 0)
func doPhotography():
	var tool_dir = DirAccess.open(tool_path)
	for t in tool_dir.get_files():
		var new_mesh = load(tool_path + t).instantiate()
		var mesh_name = t.split(".")[0]
		toolSpot.add_child(new_mesh)
		await get_tree().create_timer(0.1).timeout
		var trash_image = get_viewport().get_texture().get_image()
		var image_name = mesh_name + ".png"
		var error = trash_image.save_png("user://"+image_name)
		toolSpot.get_child(0).queue_free()
		await get_tree().create_timer(0.1).timeout
	print("PHOTOGRAPHY DONE")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"): doPhotography()
	
