extends Node

enum trash_types {PAPER, PLASTIC, METAL, GLASS, BIO}
enum paper_types {NEWSPAPER, MAGAZINE, RECEIPT, CARTON_S, CARTON_L, CARDBOARD_S, CARDBOARD_M, CARDBOARD_L, CEREAL, FAST_CUP_S, FAST_CUP_L}
enum plastic_types {WATER_S, WATER_M, WATER_L, CUP, FILM, STRAW, RINGS, LID, CAP, BOTTLE}
enum metal_types {TALL_CAN, WIDE_CAN, FOOD_CAN}
enum glass_types {BURG_BOTTLE, BORD_BOTTLE, GLASS_BOTTLE}

const trash_type_names := {
	trash_types.PAPER: "paper",
	trash_types.PLASTIC: "plastic",
	trash_types.METAL: "metal",
	trash_types.GLASS: "glass",
}

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

@onready var paper_type_data := {
	paper_types.NEWSPAPER: {"scene":preload("res://scenes/trash/newspaper.tscn"), "sub_name":"newspaper", "textures":[]}, 
	paper_types.MAGAZINE: {"scene":preload("res://scenes/trash/magazine.tscn"), "sub_name":"magazine", "textures":[]}, 
	paper_types.RECEIPT: {"scene":preload("res://scenes/trash/receipt.tscn"), "sub_name":"receipt", "textures":[]}, 
	paper_types.CARTON_S: {"scene":preload("res://scenes/trash/carton_small.tscn"), "sub_name":"carton_small", "textures":[]},
	paper_types.CARTON_L: {"scene":preload("res://scenes/trash/carton_large.tscn"), "sub_name":"carton_large", "textures":[]},
	paper_types.CARDBOARD_S: {"scene":preload("res://scenes/trash/cardboard_small.tscn"), "sub_name":"cardboard_small", "textures":[]},
	paper_types.CARDBOARD_M: {"scene":preload("res://scenes/trash/cardboard_medium.tscn"), "sub_name":"cardboard_medium", "textures":[]},
	paper_types.CARDBOARD_L: {"scene":preload("res://scenes/trash/cardboard_large.tscn"), "sub_name":"cardboard_large", "textures":[]},
	paper_types.CEREAL: {"scene":preload("res://scenes/trash/cereal_box.tscn"), "sub_name":"cereal_box", "textures":[]},
	paper_types.FAST_CUP_S: {"scene":preload("res://scenes/trash/fast_cup_small.tscn"), "sub_name":"fast_cup_small", "textures":[]},
	paper_types.FAST_CUP_L: {"scene":preload("res://scenes/trash/fast_cup_large.tscn"), "sub_name":"fast_cup_large", "textures":[]},
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

@onready var plastic_type_data := {
	plastic_types.WATER_S: {"scene":preload("res://scenes/trash/water_small.tscn"), "sub_name":"water_small", "textures":[]},
	plastic_types.WATER_M: {"scene":preload("res://scenes/trash/water_medium.tscn"), "sub_name":"water_medium", "textures":[]},
	plastic_types.WATER_L: {"scene":preload("res://scenes/trash/water_large.tscn"), "sub_name":"water_large", "textures":[]},
	plastic_types.CUP: {"scene":preload("res://scenes/trash/plastic_cup.tscn"), "sub_name":"plastic_cup", "textures":[]},
	plastic_types.FILM: {"scene":preload("res://scenes/trash/plastic_film.tscn"), "sub_name":"plastic_film", "textures":[]},
	plastic_types.STRAW: {"scene":preload("res://scenes/trash/plastic_straw.tscn"), "sub_name":"plastic_straw", "textures":[]},
	#plastic_types.RINGS: 1.0, 
	plastic_types.LID: {"scene":preload("res://scenes/trash/plastic_lid.tscn"), "sub_name":"plastic_lid", "textures":[]},
	plastic_types.CAP: {"scene":preload("res://scenes/trash/bottle_cap.tscn"), "sub_name":"bottle_cap", "textures":[]},
	plastic_types.BOTTLE: {"scene":preload("res://scenes/trash/plastic_bottle.tscn"), "sub_name":"plastic_bottle", "textures":[]},
}

const metal_type_dist := {
	metal_types.TALL_CAN: 1.0,
	metal_types.WIDE_CAN: 1.0,
	metal_types.FOOD_CAN: 1.0,
}

@onready var metal_type_data := {
	metal_types.TALL_CAN: {"scene":preload("res://scenes/trash/tall_can.tscn"), "sub_name":"tall_can", "textures":[]},
	metal_types.WIDE_CAN: {"scene":preload("res://scenes/trash/wide_can.tscn"), "sub_name":"wide_can", "textures":[]},
	metal_types.FOOD_CAN: {"scene":preload("res://scenes/trash/food_can.tscn"), "sub_name":"food_can", "textures":[]},
}

const glass_type_dist := {
	glass_types.BURG_BOTTLE: 1.0, 
	glass_types.BORD_BOTTLE: 1.0, 
	glass_types.GLASS_BOTTLE: 1.0
}

@onready var glass_type_data := {
	glass_types.BURG_BOTTLE: {"scene":preload("res://scenes/trash/burg_bottle.tscn"), "sub_name":"burg_bottle", "textures":[]},
	glass_types.BORD_BOTTLE: {"scene":preload("res://scenes/trash/bord_bottle.tscn"), "sub_name":"bord_bottle", "textures":[]},
	glass_types.GLASS_BOTTLE: {"scene":preload("res://scenes/trash/glass_bottle.tscn"), "sub_name":"glass_bottle", "textures":[]},
}

func _ready() -> void:
	loadTextures()

func loadTextures():
	for t in paper_type_data:
		var trash_name = paper_type_data[t]['sub_name']
		for x in range(5):
			paper_type_data[t]['textures'].append(load("res://assets/textures/%s/%s_%s.png" % [trash_name, trash_name, x]))
	
	for t in plastic_type_data:
		var trash_name = plastic_type_data[t]['sub_name']
		for x in range(5):
			plastic_type_data[t]['textures'].append(load("res://assets/textures/%s/%s_%s.png" % [trash_name, trash_name, x]))
	
	for t in metal_type_data:
		var trash_name = metal_type_data[t]['sub_name']
		for x in range(5):
			metal_type_data[t]['textures'].append(load("res://assets/textures/%s/%s_%s.png" % [trash_name, trash_name, x]))
			
	for t in glass_type_data:
		var trash_name = glass_type_data[t]['sub_name']
		for x in range(5):
			glass_type_data[t]['textures'].append(load("res://assets/textures/%s/%s_%s.png" % [trash_name, trash_name, x]))

func getTrash(trash_t):
	match trash_t:
		trash_types.PAPER:
			var new_paper_trash_type = getWeightedChoice(paper_type_dist)
			var new_trash = paper_type_data[new_paper_trash_type]['scene'].instantiate()
			new_trash.type = trash_t
			new_trash.sub_type = new_paper_trash_type
			return new_trash
		trash_types.PLASTIC: 
			var new_plastic_trash_type = getWeightedChoice(plastic_type_dist)
			var new_trash = plastic_type_data[new_plastic_trash_type]['scene'].instantiate()
			new_trash.type = trash_t
			new_trash.sub_type = new_plastic_trash_type
			return new_trash
		trash_types.METAL: 
			var new_metal_trash_type = getWeightedChoice(metal_type_dist)
			var new_trash = metal_type_data[new_metal_trash_type]['scene'].instantiate()
			new_trash.type = trash_t
			new_trash.sub_type = new_metal_trash_type
			return new_trash
		trash_types.GLASS:
			var new_glass_trash_type = getWeightedChoice(glass_type_dist)
			var new_trash = glass_type_data[new_glass_trash_type]['scene'].instantiate()
			new_trash.type = trash_t
			new_trash.sub_type = new_glass_trash_type
			return new_trash

func getWeightedChoice(stuff):
	var rand_pick = randf() * stuff.values().reduce(func(x, acc): return acc+x,0)
	var weight_acc := 0.0
	for choice in stuff:
		weight_acc += stuff[choice]
		if rand_pick <= weight_acc:
			return choice

func getWeightedSkin():
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

func getTexture(t, st, skin):
	match t:
		trash_types.PAPER:
			return paper_type_data[st]['textures'][skin]
		trash_types.PLASTIC: 
			return plastic_type_data[st]['textures'][skin]
		trash_types.METAL: 
			return metal_type_data[st]['textures'][skin]
		trash_types.GLASS:
			return glass_type_data[st]['textures'][skin]

func getTrashName(t, st, skin):
	match t:
		trash_types.PAPER:
			return paper_type_data[st]['sub_name'] + "_%s" % skin
		trash_types.PLASTIC: 
			return plastic_type_data[st]['sub_name'] + "_%s" % skin
		trash_types.METAL: 
			return metal_type_data[st]['sub_name'] + "_%s" % skin
		trash_types.GLASS:
			return glass_type_data[st]['sub_name'] + "_%s" % skin
