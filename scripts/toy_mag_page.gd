extends VBoxContainer
class_name ToyMagPage

@export var left := true
@export var page := 1

@onready var toyADesc := $toyHBox/toyAArea/toyVbox/toyDesc
@onready var toyBDesc := $toyHBox/toyBArea/toyVbox/toyDesc

@onready var toyAPrice := $toyHBox/toyAArea/priceLabel
@onready var toyBPrice := $toyHBox/toyBArea/priceLabel

var toy_a : String
var toy_b : String

func _ready() -> void:
	loadData()
	print("TOY A %s TOY B %s" % [toy_a, toy_b])

func loadData():
	var is_left = "left" if left else "right"
	toy_a = GameData.toy_mag_data["%s%s%s" % [is_left, page, "A"]]
	toy_b = GameData.toy_mag_data["%s%s%s" % [is_left, page, "B"]]
	
	if GameData.toy_data[toy_a]['owned']: 
		updatePrice("A", "OWNED")
	else: updatePrice("A", "%s $%s" % ["BUY", GameData.toy_data[toy_a]['price']])
	
	if GameData.toy_data[toy_b]['owned']: 
		updatePrice("B", "OWNED")
	else: updatePrice("B", "%s $%s" % ["BUY", GameData.toy_data[toy_b]['price']])
	
func updatePrice(t, p):
	match t:
		"A": toyAPrice.text = "%s" % p
		"B": toyBPrice.text = "%s" % p
		
