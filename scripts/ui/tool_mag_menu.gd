extends Control

enum pages {LEFT, MIDDLE, RIGHT}
@onready var leftButton := $leftButton
@onready var rightButton := $rightButton
@onready var magAnim := $magAnim
@onready var leftPageViewport := $leftPageViewport/leftPageSlot
@onready var rightPageViewport := $rightPageViewport/rightPageSlot
@onready var middlePageViewport := $middlePageViewport/middlePageSlot
@onready var magUI := $magUI
@onready var moneyLabel := $moneyLabel

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
	2: preload("res://scenes/mag_pages/tool_demo.tscn"),
	#3: preload("res://scenes/mag_pages/tool_left_3.tscn"),
	#4: preload("res://scenes/mag_pages/tool_demo.tscn"),
}
var right_pages := {
	0: preload("res://scenes/mag_pages/tool_right_1.tscn"),
	1: preload("res://scenes/mag_pages/tool_right_1.tscn"),
	2: preload("res://scenes/mag_pages/tool_demo.tscn"),
	#3: preload("res://scenes/mag_pages/tool_right_3.tscn"),
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
	visible = true
	can_turn_page = true
	updateMoneyLabel()
	
func turnPage(left: bool):
	if not can_turn_page: return
	can_turn_page = false
	toggleUI(false)
	if not left: 
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
			if current_page > 2: leftPageViewport.add_child(demo_page.instantiate())
			else: leftPageViewport.add_child(left_pages[current_page].instantiate())
		pages.MIDDLE:
			if middlePageViewport.get_child_count() > 0: middlePageViewport.get_children().map(func(x): x.queue_free())
			if current_page > 2: 
				middlePageViewport.add_child(demo_page.instantiate())
				return
			
			
			if dir == -1: middlePageViewport.add_child(right_pages[current_page+dir].instantiate())
			else: middlePageViewport.add_child(left_pages[current_page+dir].instantiate())
		pages.RIGHT:
			if rightPageViewport.get_child_count() > 0: rightPageViewport.get_children().map(func(x): x.queue_free())
			if current_page > 2: rightPageViewport.add_child(demo_page.instantiate())
			else: rightPageViewport.add_child(right_pages[current_page].instantiate())

func updateMiddle(page: pages, dir:int):
	if middlePageViewport.get_child_count() > 0: middlePageViewport.get_children().map(func(x): x.queue_free())
	if current_page+dir > 2: 
		middlePageViewport.add_child(demo_page.instantiate())
		return
	match page:
		pages.LEFT:
			middlePageViewport.add_child(left_pages[current_page+dir].instantiate())
		pages.RIGHT:
			middlePageViewport.add_child(right_pages[current_page+dir].instantiate())

func toggleUI(on: bool):
	magUI.visible = on
	
func updateMoneyLabel():
	moneyLabel.text = "$%s" % GameData.total_money

func toolPressed(slot):
	if leftPageViewport.get_child(0) is not ToolMagPage: return
	var tool_name : String
	match slot:
		"leftA": tool_name = leftPageViewport.get_child(0).tool_a
		"leftB": tool_name = leftPageViewport.get_child(0).tool_b
		"rightA": tool_name = rightPageViewport.get_child(0).tool_a
		"rightB": tool_name = rightPageViewport.get_child(0).tool_b
	
	if not GameData.tool_data[tool_name]["owned"]: await tryBuyTool(tool_name)
	elif GameData.tool_data[tool_name]["upgrade"] < 5: await tryUpgradeTool(tool_name)
	
	if "left" in slot: leftPageViewport.get_child(0).loadData()
	else: rightPageViewport.get_child(0).loadData()
	
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
	
