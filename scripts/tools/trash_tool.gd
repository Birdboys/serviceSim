extends Node3D
class_name TrashTool

@export var pickup_paper : bool
@export var pickup_plastic : bool
@export var pickup_metal : bool
@export var pickup_glass : bool
@export var pickup_bio : bool

@export var tool_name : String
@export var speed_mod := 1.0

signal attempt_collect_trash(t: Trash)

func _ready() -> void:
	upgrade()
	
func primaryDown():
	pass
	
func secondaryDown():
	pass
	
func primaryUp():
	pass
	
func secondaryUp():
	pass

func isTrashValid(t:Trash):
	match t.type:
		TrashData.trash_types.PAPER:
			return pickup_paper
		TrashData.trash_types.PLASTIC:
			return pickup_plastic
		TrashData.trash_types.METAL:
			return pickup_metal
		TrashData.trash_types.GLASS:
			return pickup_glass
		TrashData.trash_types.BIO:
			return pickup_bio

func equip():
	pass

func unequip():
	pass

func upgrade():
	pass
