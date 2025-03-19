extends CanvasLayer

@onready var promptLabel := $uiCont/marginCont/promptVbox/promptLabel
@onready var bagLabel := $uiCont/marginCont/bagLabel
@onready var timerLabel := $uiCont/marginCont/timerLabel
@onready var bagGrid := $uiCont/bagMarginCont/bagVbox/bagPanel/bagScroll/bagGrid
@onready var bagAnim := $bagAnim
@onready var trashIcon := preload("res://scenes/ui/trash_icon.tscn")
var trash_open := false
var bag_dim : Vector2

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
	
