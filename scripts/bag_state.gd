extends PlayerState

func enter():
	parent.UI.openTrashBag()
	
func update(delta) -> void:
	if Input.is_action_just_pressed("bag"):
		emit_signal("transitioned", self, "walkState")
		
func exit():
	parent.UI.closeTrashBag()
