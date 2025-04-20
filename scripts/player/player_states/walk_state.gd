extends PlayerState

func update(delta: float) -> void:
	if parent.velocity.length() > 0:
		parent.headAnim.play("walk")
	else:
		parent.headAnim.stop(true)
		
	if not parent.is_on_floor():
		emit_signal("transitioned", self, "fallState")
	if Input.is_action_just_pressed("jump") and parent.is_on_floor(): emit_signal("transitioned", self, "jumpState")
	if Input.is_action_just_pressed("bag"): 
		parent.velocity = Vector3.ZERO
		emit_signal("transitioned", self, "bagState")

func exit():
	parent.headAnim.stop(true)
