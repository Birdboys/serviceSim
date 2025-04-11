extends Node3D

@onready var trunk := $treeTrunk
@onready var leaves := $treeLeaves
@onready var colors := [Color.hex(0x1ebc73ff), Color.hex(0x239063ff), Color.hex(0x239063ff),Color.hex(0x239063ff),Color.hex(0x165a4cff), Color.hex(0x91db69ff), Color.hex(0xcddf6cff)]

func clearTree():
	queue_free()

func randomizeTree():
	rotation.y = randf_range(0, PI/6.0)
	leaves.mesh.surface_get_material(0).albedo_color = colors.pick_random()
	position.y -= randf_range(0, 3.0)
	position.x += randf_range(-0.5,0.5)
	position.z += randf_range(-0.5,0.5)
