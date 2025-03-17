extends CanvasLayer

@onready var promptLabel := $uiCont/marginCont/promptVbox/promptLabel
@onready var bagLabel := $uiCont/marginCont/bagLabel
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
	print(bagGrid.get_child_count())

func openTrashBag():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	bagAnim.play("open_bag")

func closeTrashBag():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	bagAnim.play_backwards("open_bag")

func updateBagLabel(v, m):
	bagLabel.text = "%s/%s" % [v, m]
