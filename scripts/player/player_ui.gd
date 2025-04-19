extends CanvasLayer

@onready var promptLabel := $uiCont/marginCont/promptVbox/promptLabel
@onready var bagLabel := $uiCont/marginCont/bagLabel
@onready var timerLabel := $uiCont/marginCont/timerLabel
@onready var bagGrid := $uiCont/bagMarginCont/bagVbox/bagPanel/bagScroll/bagGrid
@onready var hotbarCont := $uiCont/marginCont/hotbarCont
@onready var bagAnim := $bagAnim
@onready var comboHbox := $uiCont/marginCont/comboHbox
@onready var comboLabel := $uiCont/marginCont/comboHbox/VBoxContainer/comboLabel
@onready var comboBar := $uiCont/marginCont/comboHbox/VBoxContainer/comboBar
@onready var callHbox := $uiCont/marginCont/callHbox
@onready var callLabel := $uiCont/marginCont/callHbox/callLabel
@onready var callBar := $uiCont/marginCont/callHbox/callBar
@onready var trashIcon := preload("res://scenes/ui/trash_icon.tscn")
@onready var hotbarIcon := preload("res://scenes/ui/hotbar_icon.tscn")

var combo_quip := ""
var trash_open := false
var bag_dim : Vector2

const combo_quips := {
	0: "",
	1: "Combo",
	10: "Super Combo",
	20: "Trash-tastic",
	30: "Trashinator",
	40: "Trashed out",
	50: "THE TRASH MAN",
}
func _ready() -> void:
	setComboLabel(0)
	updateComboUI(0)
	updateCallUI(0)
	
func _physics_process(delta: float) -> void:
	$uiCont/marginCont/fpsLabel.text = "FPS:%s" % Engine.get_frames_per_second()

func updatePrompt(t):
	promptLabel.text = t

func initBag(dim):
	bagGrid.columns = dim.x
	bag_dim = dim
	for x in range(bag_dim.x):
		for y in range(bag_dim.y):
			var new_trash_icon = trashIcon.instantiate()
			bagGrid.add_child(new_trash_icon)

func openTrashBag():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	bagAnim.play("open_bag")

func closeTrashBag():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	bagAnim.play_backwards("open_bag")

func updateBagLabel(v, m):
	bagLabel.text = "%s/%s" % [v, m]

func updateTimerLabel(t):
	var min = int(floor(t/60))
	var sec = int(t-(min*60))
	if sec < 10: sec = "0%s" % sec
	timerLabel.text = "%s:%s" % [min, sec]

func addTrashToBag(t, num_col):
	var trash_slot = bagGrid.get_child(num_col-1)
	print(trash_slot)
	print("res://assets/trash_icons/%s.png" % t)
	trash_slot.updateTrash("res://assets/trash_icons/%s.png" % t)
	
func loadToolIcons(tools):
	for t in range(len(tools)):
		if tools[t] == "": continue
		var new_icon = hotbarIcon.instantiate()
		hotbarCont.add_child(new_icon)
		new_icon.updateIcon(tools[t])
		new_icon.updateId(t)
		new_icon.toggleSelected(t==0)

func hotbarSelect(t):
	for x in range(hotbarCont.get_child_count()):
		hotbarCont.get_child(x).toggleSelected(x==t)

func setComboLabel(t):
	if t in combo_quips: 
		combo_quip = combo_quips[t]
		comboLabel.rotation_degrees = randi_range(-15,15)
	comboLabel.text = "%s %sx" % [combo_quip, t]
	
func updateComboUI(v):
	comboHbox.modulate.a = sin(v)
	comboBar.value = v * 100.0

func updateCallUI(v):
	#v = remap(v, 0.0, 1.0, 0.1, 1.0)
	callLabel.modulate.a = sin(v)
	callBar.modulate.a = sin(v)
	callBar.value = v * 100.0
