extends Node3D

@onready var trashMesh := $trashMesh
@onready var trashCam := $camArm/trashCam
@onready var camArm := $camArm
@onready var toyPos := $toyPos

var trash_path := "res://assets/trash_meshes/"
var toy_path := "res://assets/toy_meshes/"
var texture_path := "res://assets/textures/%s/%s_%s.png"
var og_cam_pos := Vector3(0.0, 1.25, 3)

var trash_files = []
var toy_files = []
var current_trash := 0
var trash_loaded := false

func _ready() -> void:
	var trash_dir = DirAccess.open(trash_path)
	trash_files = trash_dir.get_files()
	var toy_dir = DirAccess.open(toy_path)
	toy_files = toy_dir.get_files()
	
func _process(delta: float) -> void:
	if Input.is_action_pressed("left"):
		camArm.rotate(Vector3.UP, -PI/6.0 * delta)
	elif Input.is_action_pressed("right"):
		camArm.rotate(Vector3.UP, PI/6.0 * delta)
	elif Input.is_action_pressed("forward"):
		camArm.rotate(camArm.basis.x, -PI/6.0 * delta)
	elif Input.is_action_pressed("back"):
		camArm.rotate(camArm.basis.x, PI/6.0 * delta)
	elif Input.is_action_pressed("music_pause"):
		trashCam.position.z -= 2.0 * delta
	elif Input.is_action_pressed("music_skip"):
		trashCam.position.z += 2.0 * delta
	elif Input.is_action_pressed("sprint"):
		camArm.position.y += 1.0 * delta
	elif Input.is_action_pressed("skate"):
		camArm.position.y -= 1.0 * delta
		
func loadTrash(t):
	trash_loaded = true
	var new_mesh = load(trash_path + t)
	var mesh_name = t.split(".")[0]
	if new_mesh is ArrayMesh:
		trashMesh.mesh = new_mesh
		
func loadToys(t):
	trash_loaded = true
	var new_mesh = load(toy_path + t).instantiate()
	if toyPos.get_child(0): toyPos.get_child(0).queue_free()
	toyPos.add_child(new_mesh)
	
func doTrashPhotography(t):
	var mesh_name = t.split(".")[0]
	for x in range(0,5):
		var new_texture = load(texture_path % [mesh_name, mesh_name, x])
		trashMesh.mesh.surface_get_material(0).albedo_texture = new_texture
		await RenderingServer.frame_post_draw
		await RenderingServer.frame_post_draw
		var abs = trashMesh.get_aabb()
		#trashCam.position = og_cam_pos 
		#print(abs)
		var trash_image = get_viewport().get_texture().get_image()
		var image_name = mesh_name + "_" + str(x) + ".png"
		var error = trash_image.save_png("user://pics/"+image_name)
		await get_tree().create_timer(0.1).timeout
	trash_loaded = false
	current_trash += 1

func doToyPhotography(t):
	var mesh_name = t.split(".")[0]
	if "action_figure" in mesh_name:
		for x in ["", "_a", "_b", "_c", "_o"]:
			var new_texture = load("res://assets/textures/toys/action_figure%s.png" % x)
			toyPos.get_child(0).mesh.surface_get_material(0).albedo_texture = new_texture
			await RenderingServer.frame_post_draw
			await RenderingServer.frame_post_draw
			var trash_image = get_viewport().get_texture().get_image()
			var image_name = mesh_name + x + ".png"
			var error = trash_image.save_png("user://pics/"+image_name)
			await get_tree().create_timer(0.1).timeout
		trash_loaded = false
		current_trash += 1
		return
	
	var trash_image = get_viewport().get_texture().get_image()
	var image_name = mesh_name + ".png"
	var error = trash_image.save_png("user://pics/"+image_name)
	await get_tree().create_timer(0.1).timeout
	trash_loaded = false
	current_trash += 1
	
func _unhandled_input(event: InputEvent) -> void:
	#if event.is_action_pressed("jump") and current_trash < len(trash_files): 
	if event.is_action_pressed("jump") and current_trash < len(toy_files): 
		if not trash_loaded:
			print("LOADING TRASH ", toy_files[current_trash])
			#loadTrash(trash_files[current_trash])
			loadToys(toy_files[current_trash])
		else:
			print("LOADING TRASH ", toy_files[current_trash])
			#doTrashPhotography(trash_files[current_trash])
			doToyPhotography(toy_files[current_trash])
	
