extends Node3D

@onready var toolMesh := $toolMesh
@onready var toolCam := $toolCam

var tool_path := "res://assets/tool_meshes/"
var og_cam_pos := Vector3(0.0, 1.75, 3.5)

func doPhotography():
	var tool_dir = DirAccess.open(tool_path)
	for t in tool_dir.get_files():
		var new_mesh = load(tool_path + t)
		var mesh_name = t.split(".")[0]
		if new_mesh is ArrayMesh:
			toolMesh.mesh = new_mesh
			
			var trash_image = get_viewport().get_texture().get_image()
			var image_name = mesh_name + ".png"
			var error = trash_image.save_png("user://"+image_name)
			await get_tree().create_timer(0.1).timeout

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"): doPhotography()
	
