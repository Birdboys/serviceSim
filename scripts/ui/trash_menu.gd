extends Control

@onready var saveButton := $trashMargin/trashVbox/saveButton
@onready var quitButton := $trashMargin/trashVbox/quitButton

func _ready() -> void:
	saveButton.pressed.connect(saveQuit)
	quitButton.pressed.connect(quit)
	
func loadMenu():
	visible = true
		
func reset():
	visible = false

func saveQuit():
	get_tree().quit()

func quit():
	get_tree().quit()
