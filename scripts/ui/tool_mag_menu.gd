extends Control

@onready var leftButton := $leftButton
@onready var rightButton := $rightButton
@onready var magAnim := $magAnim
var current_page := 0
var can_turn_page := true

func _ready() -> void:
	leftButton.pressed.connect(turnPage.bind(true))
	rightButton.pressed.connect(turnPage.bind(false))
	
func reset():
	visible = false
	can_turn_page = false
	if current_page != 0: magAnim.play_backwards("open_tool_mag")
	
func loadMenu():
	visible = true
	#magAnim.play("open_tool_mag")
	#await magAnim.animation_finished
	can_turn_page = true
	

func turnPage(left: bool):
	if not can_turn_page: return
	can_turn_page = false
	if left: 
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
	print(current_page)
