extends PlayerState

func enter():
	parent.velocity.x = 0
	parent.velocity.z = 0

func update(delta: float):
	if not parent.is_on_floor():
		parent.velocity.y -= parent.gravity * delta
	else:
		parent.velocity.y = 0
	parent.move_and_slide()
