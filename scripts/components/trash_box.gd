extends Area3D
class_name TrashBox

@export var paper := false
@export var plastic := false
@export var metal := false
@export var glass := false
@export var bio := false
@export var trashCol : CollisionShape3D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initPhysicsLayers()

func initPhysicsLayers():
	if paper: set_collision_layer_value(4, true)
	if plastic: set_collision_layer_value(5, true)
	if metal: set_collision_layer_value(6, true)
	if glass: set_collision_layer_value(7, true)
	if bio: set_collision_layer_value(8, true)
