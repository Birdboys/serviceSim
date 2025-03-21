extends MarginContainer

@onready var bg := $bg
@onready var idLabel := $idLabel
@onready var toolLabel := $toolLabel
@onready var toolTexture := $toolTexture
@onready var id : int

func updateIcon(t):
	toolTexture.texture = load("res://assets/tool_icons/%s.png" % (t if t != "" else "empty"))

func updateId(i):
	idLabel.text = str(i+1)
	id = i

func toggleSelected(on:bool):
	bg.modulate = Color.hex(0x9babb2ff) if on else Color.hex(0xc7dcd0ff)
