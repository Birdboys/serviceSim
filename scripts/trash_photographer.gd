extends Node3D

@onready var trashMesh := $trashMesh
@onready var trashCam := $trashCam

var trash_path := "res://assets/trash_meshes/"
var texture_path := "res://assets/textures/%s/%s_%s.png"
var og_cam_pos := Vector3(0.0, 1.75, 3.5)

func doPhotography():
	var trash_dir = DirAccess.open(trash_path)
	for t in trash_dir.get_files():
		var new_mesh = load(trash_path + t)
		var mesh_name = t.split(".")[0]
		if new_mesh is ArrayMesh:
			trashMesh.mesh = new_mesh
			for x in range(0,5):
				var new_texture = load(texture_path % [mesh_name, mesh_name, x])
				trashMesh.mesh.surface_get_material(0).albedo_texture = new_texture
				await RenderingServer.frame_post_draw
				await RenderingServer.frame_post_draw
				var abs = trashMesh.get_aabb()
				trashCam.position = og_cam_pos 
				print(abs)
				var trash_image = get_viewport().get_texture().get_image()
				var image_name = mesh_name + "_" + str(x) + ".png"
				var error = trash_image.save_png("user://"+image_name)
				await get_tree().create_timer(0.1).timeout

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"): doPhotography()
	
