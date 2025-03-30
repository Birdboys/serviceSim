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

var current_page := 0
var can_turn_page := true

var demo_page := preload("res://scenes/mag_pages/tool_demo.tscn")
var left_pages := {
	0: preload("res://scenes/mag_pages/tool_cover.tscn"),
	1: preload("res://scenes/mag_pages/tool_left_1.tscn"),
	2: preload("res://scenes/mag_pages/tool_left_2.tscn"),
	3: preload("res://scenes/mag_pages/tool_left_3.tscn"),
	4: preload("res://scenes/mag_pages/tool_demo.tscn"),
}
var right_pages := {
	0: preload("res://scenes/mag_pages/tool_right_1.tscn"),
	1: preload("res://scenes/mag_pages/tool_right_1.tscn"),
	2: preload("res://scenes/mag_pages/tool_right_2.tscn"),
	3: preload("res://scenes/mag_pages/tool_right_3.tscn"),
	4: preload("res://scenes/mag_pages/tool_demo.tscn"),
}

func _ready() -> void:
	leftButton.pressed.connect(turnPage.bind(true))
	rightButton.pressed.connect(turnPage.bind(false))
	
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
	print(current_page)

func updatePage(page: pages, dir: int):
	print("CHANGING PAGE %s to %s" % [page, current_page])
	match page:
		pages.LEFT:
			print("CHANGING LEFT PAGE")
			if leftPageViewport.get_child_count() > 0: leftPageViewport.get_children().map(func(x): x.queue_free())
			if current_page > 3: leftPageViewport.add_child(demo_page.instantiate())
			else: leftPageViewport.add_child(left_pages[current_page].instantiate())
			print(leftPageViewport.get_children())
		pages.MIDDLE:
			if middlePageViewport.get_child_count() > 0: middlePageViewport.get_children().map(func(x): x.queue_free())
			if current_page > 3: 
				middlePageViewport.add_child(demo_page.instantiate())
				return
			
			
			if dir == -1: middlePageViewport.add_child(right_pages[current_page+dir].instantiate())
			else: middlePageViewport.add_child(left_pages[current_page+dir].instantiate())
		pages.RIGHT:
			if rightPageViewport.get_child_count() > 0: rightPageViewport.get_children().map(func(x): x.queue_free())
			if current_page > 3: rightPageViewport.add_child(demo_page.instantiate())
			else: rightPageViewport.add_child(right_pages[current_page].instantiate())

func updateMiddle(page: pages, dir:int):
	if middlePageViewport.get_child_count() > 0: middlePageViewport.get_children().map(func(x): x.queue_free())
	if current_page > 3: 
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
