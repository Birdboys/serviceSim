extends CanvasLayer

@onready var quitButton := $pauseMargin/pauseVbox/quitButton
@onready var noticeLabel := $pauseMargin/pauseVbox/noticeLabel

var can_pause := false

signal game_paused(on:bool)

func _ready() -> void:
	quitButton.mouse_entered.connect(toggleNotice.bind(true))
	quitButton.mouse_exited.connect(toggleNotice.bind(false))
	quitButton.pressed.connect(get_tree().quit)
	toggleNotice(false)
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("escape") and can_pause:
		if get_tree().paused: #unpause
			visible = false
			get_tree().paused = false
			emit_signal("game_paused", false)
			print("UNPAUSED")
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		else: #pause
			emit_signal("game_paused", true)
			visible = true
			get_tree().paused = true
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func toggleNotice(on: bool):
	noticeLabel.modulate = Color.hex(0xffffffcc) if on else Color.TRANSPARENT
