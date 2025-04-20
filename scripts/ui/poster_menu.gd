extends Control

@onready var paperBar := $posterViewport/posterMargin/dataVbox/posterHbox/graphVbox/paperData/paperBar
@onready var plasticBar := $posterViewport/posterMargin/dataVbox/posterHbox/graphVbox/plasticData/plasticBar
@onready var metalBar := $posterViewport/posterMargin/dataVbox/posterHbox/graphVbox/metalData/metalBar
@onready var glassBar := $posterViewport/posterMargin/dataVbox/posterHbox/graphVbox/glassData/glassBar
@onready var figBar := $posterViewport/posterMargin/dataVbox/posterHbox/figureVbox/VBoxContainer/figureProgress
@onready var trashLabel := $posterViewport/posterMargin/dataVbox/labelHbox/trashLabel
@onready var valueLabel := $posterViewport/posterMargin/dataVbox/labelHbox/valueLabel

func reset():
	visible = false
	updatePoster()

func loadMenu():
	visible = true
	updatePoster()

func updatePoster():
	valueLabel.text = "CREDITS: %s" % GameData.total_money
	trashLabel.text = "TRASH: %s" % GameData.total_trash_collected
	
	paperBar.custom_minimum_size.x = 345.0 * (GameData.trash_data['paper']/1000.0)
	plasticBar.custom_minimum_size.x = 345.0 * (GameData.trash_data['plastic']/1000.0)
	metalBar.custom_minimum_size.x = 345.0 * (GameData.trash_data['metal']/1000.0)
	glassBar.custom_minimum_size.x = 345.0 * (GameData.trash_data['glass']/1000.0)
	figBar.value = min(100.0, (float(GameData.total_money)/float(GameData.toy_data['action_figure']['price']))*100.0)
	print(figBar.value)
