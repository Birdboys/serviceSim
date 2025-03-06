extends PlayerState

func update(delta: float) -> void:
	if parent.is_on_floor():
		emit_signal("transitioned", self, "walkState")
