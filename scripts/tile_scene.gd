extends Node3D
class_name TileScene

@onready var trashScatterer := $trashScatterer
@onready var houses := $houses
@onready var rockbeds := $rockBeds
@onready var cars := $cars
@export var auto_rotate := false
var scattered := false


func _ready() -> void:
	if auto_rotate:
		rotation.y = PI/2.0 * randi_range(0,3)
		
func initTrash():
	if scattered: return
	scattered = true
	await doHouses()
	await doRockBeds()
	await doCars()
	await trashScatterer.initTrash()

func doHouses():
	for h in houses.get_children():
		h.randomizeHouse()
		await get_tree().process_frame

func doRockBeds():
	for r in rockbeds.get_children():
		r.randomizeRockBed()
	rockbeds.visible = true

func doCars():
	for c in cars.get_children():
		if randf() < 0.15:
			var new_car = GameData.car_meshes.pick_random().instantiate()
			c.add_child(new_car)
			new_car.randomizeCar()
			new_car.moveCar()
		else:
			c.queue_free()
