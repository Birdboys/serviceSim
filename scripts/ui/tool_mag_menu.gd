extends Control

enum pages {LEFT, MIDDLE, RIGHT}
@onready var leftButton := $leftButton
@onready var rightButton := $rightButton
@onready var magAnim := $toolMagAnim
@onready var resetAnim := $resetAnim
@onready var leftPageViewport := $leftPageViewport/leftPageSlot
@onready var rightPageViewport := $rightPageViewport/rightPageSlot
@onready var middlePageViewport := $middlePageViewport/middlePageSlot
@onready var magUI := $magUI
@onready var moneyLabel := $moneyLabel
@onready var buttonLabel := $buttonLabel

@onready var toolALeftButton := $magUI/leftPageButton/toolALeftButton
@onready var toolBLeftButton := $magUI/leftPageButton/toolBLeftButton
@onready var toolARightButton := $magUI/rightPageButton/toolARightButton
@onready var toolBRightButton := $magUI/rightPageButton/toolBRightButton

var current_page := 0
var can_turn_page := true

var demo_page := preload("res://scenes/mag_pages/tool_demo.tscn")
var left_pages := {
	0: preload("res://scenes/mag_pages/tool_cover.tscn"),
	1: preload("res://scenes/mag_pages/tool_left_1.tscn"),
	2: preload("res://scenes/mag_pages/tool_left_2.tscn"),
	3: preload("res://scenes/mag_pages/tool_left_3.tscn"),
	#4: preload("res://scenes/mag_pages/tool_demo.tscn"),
}
var right_pages := {
	0: preload("res://scenes/mag_pages/tool_right_1.tscn"),
	1: preload("res://scenes/mag_pages/tool_right_1.tscn"),
	2: preload("res://scenes/mag_pages/tool_right_2.tscn"),
	3: preload("res://scenes/mag_pages/tool_right_3.tscn"),
	#4: preload("res://scenes/mag_pages/tool_demo.tscn"),
}

signal tool_purchased

func _ready() -> void:
	leftButton.pressed.connect(turnPage.bind(true))
	rightButton.pressed.connect(turnPage.bind(false))
	
	toolALeftButton.pressed.connect(toolPressed.bind("leftA"))
	toolBLeftButton.pressed.connect(toolPressed.bind("leftB"))
	toolARightButton.pressed.connect(toolPressed.bind("rightA"))
	toolBRightButton.pressed.connect(toolPressed.bind("rightB"))
	
	toolALeftButton.mouse_entered.connect(updateButtonLabel.bind("leftA"))
	toolBLeftButton.mouse_entered.connect(updateButtonLabel.bind("leftB"))
	toolARightButton.mouse_entered.connect(updateButtonLabel.bind("rightA"))
	toolBRightButton.mouse_entered.connect(updateButtonLabel.bind("rightB"))
	
	toolALeftButton.mouse_exited.connect(updateButtonLabel.bind(""))
	toolBLeftButton.mouse_exited.connect(updateButtonLabel.bind(""))
	toolARightButton.mouse_exited.connect(updateButtonLabel.bind(""))
	toolBRightButton.mouse_exited.connect(updateButtonLabel.bind(""))
	
func reset():
	visible = false
	can_turn_page = false
	if current_page != 0: magAnim.play_backwards("open_tool_mag")
	current_page = 0
	if leftPageViewport.get_child_count() > 0: leftPageViewport.get_children().map(func(x): x.queue_free())
	if rightPageViewport.get_child_count() > 0: rightPageViewport.get_children().map(func(x): x.queue_free())
	if middlePageViewport.get_child_count() > 0: middlePageViewport.get_children().map(func(x): x.queue_free())
	magUI.visible = false
	
func loadMenu():
	#var screen_size := DisplayServer.window_get_size()
	#print(screen_size)
	#magUI.custom_minimum_size.x = 900.0 * screen_size.x/1280.0
	#magUI.custom_minimum_size.y = 620.0 * screen_size.y/720.0
	visible = true
	can_turn_page = true
	updateMoneyLabel()
	
func turnPage(left: bool):
	if not can_turn_page: return
	can_turn_page = false
	toggleUI(false)
	if not left: 
		if current_page == 3: 
			can_turn_page = true
			toggleUI(true)
			return
		if current_page == 0: magAnim.play("open_tool_mag")
		else: magAnim.play("turn_page_left")
		current_page += 1
	else: 
		if current_page == 0: 
			can_turn_page = true
			return
		if current_page == 1: 
			magAnim.play_backwards("open_tool_mag")
		else: magAnim.play("turn_page_right")
		current_page -= 1
	
	await magAnim.animation_finished
	can_turn_page = true
	toggleUI(current_page != 0)

func updatePage(page: pages, dir: int):
	match page:
		pages.LEFT:
			if leftPageViewport.get_child_count() > 0: leftPageViewport.get_children().map(func(x): x.queue_free())
			leftPageViewport.add_child(left_pages[current_page].instantiate())
		pages.MIDDLE:
			if middlePageViewport.get_child_count() > 0: middlePageViewport.get_children().map(func(x): x.queue_free())
	
			if dir == -1: middlePageViewport.add_child(right_pages[current_page+dir].instantiate())
			else: middlePageViewport.add_child(left_pages[current_page+dir].instantiate())
		pages.RIGHT:
			if rightPageViewport.get_child_count() > 0: rightPageViewport.get_children().map(func(x): x.queue_free())
			rightPageViewport.add_child(right_pages[current_page].instantiate())

func updateMiddle(page: pages, dir:int):
	if middlePageViewport.get_child_count() > 0: middlePageViewport.get_children().map(func(x): x.queue_free())
	match page:
		pages.LEFT:
			middlePageViewport.add_child(left_pages[current_page+dir].instantiate())
		pages.RIGHT:
			middlePageViewport.add_child(right_pages[current_page+dir].instantiate())

func toggleUI(on: bool):
	print("TOGGLING UI for %s page %s" % [current_page, on])
	magUI.visible = on
	
func updateMoneyLabel():
	moneyLabel.text = "$%s" % GameData.total_money

func toolPressed(slot):
	if rightPageViewport.get_child(0) is not ToolMagPage: return
	var tool_name : String
	match slot:
		"leftA": 
			if leftPageViewport.get_child(0) is ToolMagPage:
				tool_name = leftPageViewport.get_child(0).tool_a
			else: return
		"leftB":
			if leftPageViewport.get_child(0) is ToolMagPage:
				tool_name = leftPageViewport.get_child(0).tool_b
			else: return
		"rightA": tool_name = rightPageViewport.get_child(0).tool_a
		"rightB": tool_name = rightPageViewport.get_child(0).tool_b
	if not GameData.tool_data[tool_name]["owned"]: await tryBuyTool(tool_name)
	elif GameData.tool_data[tool_name]["upgrade"] < 5: await tryUpgradeTool(tool_name)
	
	if "left" in slot: leftPageViewport.get_child(0).loadData()
	else: rightPageViewport.get_child(0).loadData()
	updateButtonLabel(slot)
	
func tryBuyTool(t):
	var tool_price = GameData.tool_data[t]['price']
	if tool_price > GameData.total_money: return
	GameData.total_money -= tool_price
	GameData.tool_data[t]['owned'] = true
	moneyLabel.text = "$%s" % GameData.total_money
	emit_signal("tool_purchased")
	
func tryUpgradeTool(t):
	var upgrade_price = GameData.tool_data[t]['upgrade_price']
	if upgrade_price > GameData.total_money: return
	GameData.total_money -= upgrade_price
	GameData.tool_data[t]['upgrade'] += 1
	moneyLabel.text = "$%s" % GameData.total_money
	
func updateButtonLabel(b):
	if rightPageViewport.get_child(0) is not ToolMagPage: return
	var tool_name : String
	var label_text : String
	match b:
		"leftA": 
			if leftPageViewport.get_child(0) is ToolMagPage:
				tool_name = leftPageViewport.get_child(0).tool_a
			else:
				buttonLabel.text = ""
				return 
		"leftB": 
			if leftPageViewport.get_child(0) is ToolMagPage:
				tool_name = leftPageViewport.get_child(0).tool_b
			else:
				buttonLabel.text = ""
				return 
		"rightA": tool_name = rightPageViewport.get_child(0).tool_a
		"rightB": tool_name = rightPageViewport.get_child(0).tool_b
		_: 
			buttonLabel.text = ""
			return 
	if not GameData.tool_data[tool_name]['owned']:
		if GameData.tool_data[tool_name]['price'] > GameData.total_money:
			label_text = "Insufficient funds"
		else:	
			label_text = "Click to buy %s" % GameData.tool_data[tool_name]["name"]
	else:
		if GameData.tool_data[tool_name]['upgrade'] < 5:
			label_text = "Click to upgrade %s" % GameData.tool_data[tool_name]["name"]
		else:
			label_text = "%s is fully upgraded" % GameData.tool_data[tool_name]["name"]
	buttonLabel.text = label_text

func resetMiddle():
	print("MIDDLE RESET")
	resetAnim.play("reset_middle")
