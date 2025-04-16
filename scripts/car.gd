extends StaticBody3D

@onready var carMesh := $carMesh
@onready var trashScatterer := $trashScatterer

func randomizeCar():
	carMesh.mesh.surface_get_material(0).albedo_texture = GameData.car_textures.pick_random()
	trashScatterer.num_trash = randi_range(2,6)
	trashScatterer.initTrash()
	position.x += randi_range(-5,5)
