extends Node3D

@onready var trunk := $treeTrunk
@onready var leaves := $treeLeaves
@onready var trashSurfaceScatterer := $treeLeaves/trashSurfaceScatterer
@onready var colors := [Color.hex(0x1ebc73ff), Color.hex(0x239063ff), Color.hex(0x239063ff),Color.hex(0x239063ff),Color.hex(0x165a4cff), Color.hex(0x91db69ff), Color.hex(0xcddf6cff)]

func clearTree():
	queue_free()

func randomizeTree():
	trashSurfaceScatterer.num_trash = randi_range(2, 6)
	if randf() < 0.3: await trashSurfaceScatterer.initTrash()
	
	rotation.y = randf_range(0, PI/6.0)
	leaves.mesh.surface_get_material(0).albedo_color = colors.pick_random()
	position.y -= randf_range(0, 3.0)
	position.x += randf_range(-1,1)
	position.z += randf_range(-1,1)
	var scale_mod = randf_range(0.75,1.25)
	scale.x = scale_mod
	scale.z = scale_mod
