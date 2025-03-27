extends CanvasLayer

@onready var endCont := $endMenuCont
@onready var bedButton := $endMenuCont/endMargin/endVbox/endButtonHbox/bedButton
@onready var quitButton := $endMenuCont/endMargin/endVbox/endButtonHbox/quitButton
@onready var trashLabel := $endMenuCont/endMargin/endVbox/trashHBox/trashCountLabel
@onready var moneyLabel := $endMenuCont/endMargin/endVbox/moneyHbox/moneyCountLabel
@onready var comboLabel := $endMenuCont/endMargin/endVbox/comboHbox/comboCountLabel
@onready var endAnim := $endAnim

@export var trash_percent := 0.0
@export var value_percent := 0.0
@export var combo_percent := 0.0
@export var loading_stats := false

var left := false


var num_trash := 0
var trash_val := 0
var max_combo := 0

signal to_bedroom 
signal quit_game

func _ready() -> void:
	bedButton.pressed.connect(toBedroom)
	quitButton.pressed.connect(quitGame)
	reset()
	
func _physics_process(delta: float) -> void:
	if loading_stats: 
		trashLabel.text = "%s pieces" % int(num_trash * trash_percent)
		moneyLabel.text = "%s dollars" % int(trash_val * value_percent)
		comboLabel.text = "%s" % int(max_combo * combo_percent)
	
func reset():
	visible = false
	endCont.modulate = Color.TRANSPARENT
	
func toBedroom():
	if left: return
	left = true
	endAnim.play("transition_to_bed")

func quitGame():
	emit_signal("quit_game")

func loadMenu(t, v, c):
	num_trash = t
	trash_val = v
	max_combo = c
	endAnim.play("load_end_menu")

func showStats():
	endAnim.play("load_stats", -1, 0.5)
