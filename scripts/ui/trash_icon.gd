extends MarginContainer

@onready var trashTexture := $trashTexture

func updateTrash(trash_path):
	trashTexture.texture = load(trash_path)
