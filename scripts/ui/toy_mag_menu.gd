extends Control

enum pages {LEFT, MIDDLE, RIGHT}
@onready var leftButton := $leftButton
@onready var rightButton := $rightButton
@onready var magAnim := $toyMagAnim
@onready var resetAnim := $resetAnim
@onready var leftPageViewport := $leftPageViewport/leftPageSlot
@onready var rightPageViewport := $rightPageViewport/rightPageSlot
@onready var middlePageViewport := $middlePageViewport/middlePageSlot
@onready var magUI := $magUI
@onready var moneyLabel := $moneyLabel
@onready var buttonLabel := $buttonLabel

@onready var toyALeftButton := $magUI/leftPageButton/toyALeftButton
@onready var toyBLeftButton := $magUI/leftPageButton/toyBLeftButton
@onready var toyARightButton := $magUI/rightPageButton/toyARightButton
@onready var toyBRightButton := $magUI/rightPageButton/toyBRightButton

var current_page := 0
var can_turn_page := true

var demo_page := preload("res://scenes/mag_pages/tool_demo.tscn")
var left_pages := {
	0: preload("res://scenes/mag_pages/toy_cover.tscn"),
	1: preload("res://scenes/mag_pages/toy_left_1.tscn"),
	2: preload("res://scenes/mag_pages/toy_left_2.tscn"),
	3: preload("res://scenes/mag_pages/toy_left_3.tscn"),
	4: preload("res://scenes/mag_pages/toy_left_4.tscn"),
}
var right_pages := {
	0: preload("res://scenes/mag_pages/toy_right_1.tscn"),
	1: preload("res://scenes/mag_pages/toy_right_1.tscn"),
	2: preload("res://scenes/mag_pages/toy_right_2.tscn"),
	3: preload("res://scenes/mag_pages/toy_right_3.tscn"),
	4: preload("res://scenes/mag_pages/toy_right_4.tscn"),
}

signal toy_purchased

func _ready() -> void:
	leftButton.pressed.connect(turnPage.bind(true))
	rightButton.pressed.connect(turnPage.bind(false))
	
	toyALeftButton.pressed.connect(toyPressed.bind("leftA"))
	toyBLeftButton.pressed.connect(toyPressed.bind("leftB"))
	toyARightButton.pressed.connect(toyPressed.bind("rightA"))
	toyBRightButton.pressed.connect(toyPressed.bind("rightB"))
	
	toyALeftButton.mouse_entered.connect(updateButtonLabel.bind("leftA"))
	toyBLeftButton.mouse_entered.connect(updateButtonLabel.bind("leftB"))
	toyARightButton.mouse_entered.connect(updateButtonLabel.bind("rightA"))
	toyBRightButton.mouse_entered.connect(updateButtonLabel.bind("rightB"))
	
	toyALeftButton.mouse_exited.connect(updateButtonLabel.bind(""))
	toyBLeftButton.mouse_exited.connect(updateButtonLabel.bind(""))
	toyARightButton.mouse_exited.connect(updateButtonLabel.bind(""))
	toyBRightButton.mouse_exited.connect(updateButtonLabel.bind(""))
	
func reset():
	visible = false
	can_turn_page = false
	if current_page != 0: magAnim.play_backwards("open_toy_mag")
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
		if current_page == 3 and not GameData.toy_data['action_figure']['owned']: 
			can_turn_page = true
			toggleUI(true)
			return
		elif current_page == 4:
			can_turn_page = true
			toggleUI(true)
			return
		if current_page == 0: magAnim.play("open_toy_mag")
		else: magAnim.play("turn_page_left")
		current_page += 1
	else: 
		if current_page == 0: 
			can_turn_page = true
			return
		if current_page == 1: 
			magAnim.play_backwards("open_toy_mag")
		else: magAnim.play("turn_page_right")
		current_page -= 1
	
	await magAnim.animation_finished
	can_turn_page = true
	toggleUI(current_page != 0)

func updatePage(page: pages, dir: int):
	match page:
		pages.LEFT:
			if leftPageViewport.get_child_count() > 0: leftPageViewport.get_children().map(func(x): x.queue_free())
			if current_page > 4: leftPageViewport.add_child(demo_page.instantiate())
			else: leftPageViewport.add_child(left_pages[current_page].instantiate())
		pages.MIDDLE:
			if middlePageViewport.get_child_count() > 0: middlePageViewport.get_children().map(func(x): x.queue_free())
			if current_page > 4: 
				middlePageViewport.add_child(demo_page.instantiate())
				return
			
			
			if dir == -1: middlePageViewport.add_child(right_pages[current_page+dir].instantiate())
			else: middlePageViewport.add_child(left_pages[current_page+dir].instantiate())
		pages.RIGHT:
			if rightPageViewport.get_child_count() > 0: rightPageViewport.get_children().map(func(x): x.queue_free())
			if current_page > 4: rightPageViewport.add_child(demo_page.instantiate())
			else: rightPageViewport.add_child(right_pages[current_page].instantiate())

func updateMiddle(page: pages, dir:int):
	if middlePageViewport.get_child_count() > 0: middlePageViewport.get_children().map(func(x): x.queue_free())
	if current_page+dir > 4: 
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

func toyPressed(slot):
	if rightPageViewport.get_child(0) is not ToyMagPage: return
	var toy_name : String
	match slot:
		"leftA": 
			if leftPageViewport.get_child(0) is ToyMagPage:
				toy_name = leftPageViewport.get_child(0).toy_a
			else: return
		"leftB": 
			if leftPageViewport.get_child(0) is ToyMagPage:
				toy_name = leftPageViewport.get_child(0).toy_b
			else: return
		"rightA": toy_name = rightPageViewport.get_child(0).toy_a
		"rightB": toy_name = rightPageViewport.get_child(0).toy_b
	
	if GameData.toy_data[toy_name]["owned"]: return
	else: tryBuyToy(toy_name)
	
	if "left" in slot: leftPageViewport.get_child(0).loadData()
	else: rightPageViewport.get_child(0).loadData()
	updateButtonLabel(slot)
	
func tryBuyToy(t):
	var toy_price = GameData.toy_data[t]['price']
	if toy_price > GameData.total_money: return
	GameData.total_money -= toy_price
	GameData.toy_data[t]['owned'] = true
	moneyLabel.text = "$%s" % GameData.total_money
	emit_signal("toy_purchased")
	if t == "utility_belt": GameData.current_gear.append("")

	
func updateButtonLabel(b):
	if rightPageViewport.get_child(0) is not ToyMagPage: return
	var toy_name : String
	var label_text : String
	match b:
		"leftA": 
			if leftPageViewport.get_child(0) is ToyMagPage:
				toy_name = leftPageViewport.get_child(0).toy_a
			else: return
		"leftB": 
			if leftPageViewport.get_child(0) is ToyMagPage:
				toy_name = leftPageViewport.get_child(0).toy_b
			else: return
		"rightA": toy_name = rightPageViewport.get_child(0).toy_a
		"rightB": toy_name = rightPageViewport.get_child(0).toy_b
		_: 
			buttonLabel.text = ""
			return 
	if not GameData.toy_data[toy_name]['owned']:
		if GameData.toy_data[toy_name]['price'] > GameData.total_money:
			label_text = "Insufficient funds"
		else:	
			label_text = "Click to purchase %s" % GameData.toy_data[toy_name]["name"]
	else:
		label_text = "%s already owned" % GameData.toy_data[toy_name]["name"]
	buttonLabel.text = label_text

func resetMiddle():
	print("MIDDLE RESET")
	resetAnim.play("reset_middle")
