extends Node

enum trash_types {PAPER, PLASTIC, METAL, GLASS, BIO}
enum paper_types {NEWSPAPER, MAGAZINE, RECEIPT, CARTON_S, CARTON_L, CARDBOARD_S, CARDBOARD_M, CARDBOARD_L, CEREAL, FAST_CUP_S, FAST_CUP_L}
enum plastic_types {WATER_S, WATER_M, WATER_L, CUP, FILM, STRAW, RINGS, LID, CAP, BOTTLE}
enum metal_types {TALL_CAN, WIDE_CAN, FOOD_CAN}
enum glass_types {BURG_BOTTLE, BORD_BOTTLE, GLASS_BOTTLE}

const paper_type_dist := {
	paper_types.NEWSPAPER:1.0, 
	paper_types.MAGAZINE:1.0, 
	paper_types.RECEIPT:1.0, 
	paper_types.CARTON_S:1.0, 
	paper_types.CARTON_L:1.0, 
	paper_types.CARDBOARD_S:1.0, 
	paper_types.CARDBOARD_M:1.0, 
	paper_types.CARDBOARD_L:1.0, 
	paper_types.CEREAL:1.0, 
	paper_types.FAST_CUP_S:1.0, 
	paper_types.FAST_CUP_L:1.0
}

const paper_type_scenes := {
	paper_types.NEWSPAPER:preload("res://scenes/trash/newspaper.tscn"), 
	paper_types.MAGAZINE:preload("res://scenes/trash/magazine.tscn"), 
	paper_types.RECEIPT:preload("res://scenes/trash/receipt.tscn"), 
	paper_types.CARTON_S:preload("res://scenes/trash/carton_small.tscn"), 
	paper_types.CARTON_L:preload("res://scenes/trash/carton_large.tscn"), 
	paper_types.CARDBOARD_S:preload("res://scenes/trash/cardboard_small.tscn"), 
	paper_types.CARDBOARD_M:preload("res://scenes/trash/cardboard_medium.tscn"), 
	paper_types.CARDBOARD_L:preload("res://scenes/trash/cardboard_large.tscn"), 
	paper_types.CEREAL:preload("res://scenes/trash/cereal_box.tscn"), 
	paper_types.FAST_CUP_S:preload("res://scenes/trash/fast_cup_small.tscn"), 
	paper_types.FAST_CUP_L:preload("res://scenes/trash/fast_cup_large.tscn")
}
const plastic_type_dist := {
	plastic_types.WATER_S: 1.0, 
	plastic_types.WATER_M: 1.0, 
	plastic_types.WATER_L: 1.0, 
	plastic_types.CUP: 1.0, 
	plastic_types.FILM: 1.0, 
	plastic_types.STRAW: 1.0, 
	#plastic_types.RINGS: 1.0, 
	plastic_types.LID: 1.0, 
	plastic_types.CAP: 1.0, 
	plastic_types.BOTTLE: 1.0
}

const plastic_type_scenes := {
	plastic_types.WATER_S: preload("res://scenes/trash/water_small.tscn"), 
	plastic_types.WATER_M: preload("res://scenes/trash/water_medium.tscn"), 
	plastic_types.WATER_L: preload("res://scenes/trash/water_large.tscn"), 
	plastic_types.CUP: preload("res://scenes/trash/plastic_cup.tscn"), 
	plastic_types.FILM: preload("res://scenes/trash/plastic_film.tscn"), 
	plastic_types.STRAW: preload("res://scenes/trash/plastic_straw.tscn"), 
	#plastic_types.RINGS: 1.0, 
	plastic_types.LID: preload("res://scenes/trash/plastic_lid.tscn"), 
	plastic_types.CAP: preload("res://scenes/trash/bottle_cap.tscn"), 
	plastic_types.BOTTLE: preload("res://scenes/trash/plastic_bottle.tscn")
}

const metal_type_dist := {
	metal_types.TALL_CAN: 1.0,
	metal_types.WIDE_CAN: 1.0,
	metal_types.FOOD_CAN: 1.0,
}

const metal_type_scenes := {
	metal_types.TALL_CAN: preload("res://scenes/trash/tall_can.tscn"),
	metal_types.WIDE_CAN: preload("res://scenes/trash/wide_can.tscn"),
	metal_types.FOOD_CAN: preload("res://scenes/trash/food_can.tscn"),
}

const glass_type_dist := {
	glass_types.BURG_BOTTLE: 1.0, 
	glass_types.BORD_BOTTLE: 1.0, 
	glass_types.GLASS_BOTTLE: 1.0
}

const glass_type_scenes := {
	glass_types.BURG_BOTTLE: preload("res://scenes/trash/burg_bottle.tscn"), 
	glass_types.BORD_BOTTLE: preload("res://scenes/trash/bord_bottle.tscn"), 
	glass_types.GLASS_BOTTLE: preload("res://scenes/trash/glass_bottle.tscn")
}

func getTrash(trash_t):
	match trash_t:
		trash_types.PAPER:
			var new_paper_trash_type = getWeightedChoice(paper_type_dist)
			var new_trash = paper_type_scenes[new_paper_trash_type].instantiate()
			return new_trash
		trash_types.PLASTIC: 
			var new_plastic_trash_type = getWeightedChoice(plastic_type_dist)
			var new_trash = plastic_type_scenes[new_plastic_trash_type].instantiate()
			return new_trash
		trash_types.METAL: 
			var new_metal_trash_type = getWeightedChoice(metal_type_dist)
			var new_trash = metal_type_scenes[new_metal_trash_type].instantiate()
			return new_trash
		trash_types.GLASS:
			var new_glass_trash_type = getWeightedChoice(glass_type_dist)
			var new_trash = glass_type_scenes[new_glass_trash_type].instantiate()
			return new_trash

func getWeightedChoice(stuff):
	var rand_pick = randf() * stuff.values().reduce(func(x, acc): return acc+x,0)
	var weight_acc := 0.0
	for choice in stuff:
		weight_acc += stuff[choice]
		if rand_pick <= weight_acc:
			return choice

func getWeightedSubtype():
	var rand_type = randf()
	if rand_type < 0.4:
		return 0
	elif rand_type < 0.55:
		return 1
	elif rand_type < 0.70:
		return 2 
	elif rand_type < 0.95:
		return 3
	else:
		return 4
