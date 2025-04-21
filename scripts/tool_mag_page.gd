extends VBoxContainer
class_name ToolMagPage

@export var left := true
@export var page := 1

@export_multiline var tool_a_desc : String
@export_multiline var tool_b_desc : String

@onready var toolADesc := $toolAArea/toolCont/VBoxContainer/toolDesc
@onready var toolBDesc := $toolAArea2/toolCont/VBoxContainer/toolDesc

@onready var toolAPrice := $toolAArea/priceLabel
@onready var toolBPrice := $toolAArea2/priceLabel

var tool_a : String
var tool_b : String

func _ready() -> void:
	loadData()

func loadData():
	var is_left = "left" if left else "right"
	tool_a = GameData.tool_mag_data["%s%s%s" % [is_left, page, "A"]]
	tool_b = GameData.tool_mag_data["%s%s%s" % [is_left, page, "B"]]
	
	if GameData.tool_data[tool_a]['owned']: 
		if GameData.tool_data[tool_a]['upgrade'] == 5: updatePrice("A", "COMPLETED")
		else: updatePrice("A", "%s $%s" % ["UPGRADE", GameData.tool_data[tool_a]['upgrade_price']])
	else: updatePrice("A", "%s $%s" % ["BUY", GameData.tool_data[tool_a]['price']])
	toolADesc.text = tool_a_desc % int(GameData.tool_data[tool_a]['upgrade'])
	
	if GameData.tool_data[tool_b]['owned']: 
		if GameData.tool_data[tool_b]['upgrade'] == 5: updatePrice("B", "COMPLETED")
		else: updatePrice("B", "%s $%s" % ["UPGRADE",GameData.tool_data[tool_b]['upgrade_price']])
	else: updatePrice("B", "%s $%s" % ["BUY", GameData.tool_data[tool_b]['price']])
	toolBDesc.text = tool_b_desc % int(GameData.tool_data[tool_b]['upgrade'])

func updatePrice(t, p):
	match t:
		"A": toolAPrice.text = "%s" % p
		"B": toolBPrice.text = "%s" % p
