extends PlayerState

func update(delta: float) -> void:
	if parent.is_on_floor():
		parent.handleFootstep()
		emit_signal("transitioned", self, "walkState")
	if parent.has_cape and Input.is_action_pressed("jump"):
		parent.velocity.y = max(-1.5, parent.velocity.y)
