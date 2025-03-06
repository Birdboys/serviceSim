extends PlayerState

@export var jump_strength := 6.0

func enter():
	parent.velocity.y = jump_strength

func update(delta):
	if parent.velocity.y < 0:
		emit_signal("transitioned", self, "fallState")
	if parent.is_on_floor():
		emit_signal("transitioned", self, "walkState")
