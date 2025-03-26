extends CanvasLayer

@onready var quitButton := $pauseMargin/pauseVbox/quitButton
@onready var noticeLabel := $pauseMargin/pauseVbox/noticeLabel
@onready var musicSlider := $pauseMargin/pauseVbox/musicSlider/musicSlider
@onready var soundSlider := $pauseMargin/pauseVbox/soundSlider/soundSlider
@onready var sensitivitySlider := $pauseMargin/pauseVbox/sensitivitySlider/sensitivitySlider
@onready var fovSlider := $pauseMargin/pauseVbox/fovSlider/fovSlider
var can_pause := false

signal game_paused(on:bool)
signal sens_updated
signal fov_updated

func _ready() -> void:
	sensitivitySlider.value_changed.connect(updateSensitivity)
	fovSlider.value_changed.connect(updateFOV)
	musicSlider.value_changed.connect(updateMusic)
	soundSlider.value_changed.connect(updateSound)
	
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
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		else: #pause
			emit_signal("game_paused", true)
			setSliders()
			visible = true
			get_tree().paused = true
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func toggleNotice(on: bool):
	noticeLabel.modulate = Color.hex(0xffffffcc) if on else Color.TRANSPARENT

func updateMusic(v):
	GameData.settings_data['music'] = v/100.0
	AudioHandler.loadAudioSettings()
	
func updateSound(v):
	GameData.settings_data['sound'] = v/100.0
	AudioHandler.loadAudioSettings()

func updateSensitivity(v):
	GameData.settings_data['sensitivity'] = v
	emit_signal("sens_updated")

func updateFOV(v):
	GameData.settings_data['fov'] = v
	emit_signal("fov_updated")
	
func setSliders():
	musicSlider.value = GameData.settings_data['music'] * 100.0
	soundSlider.value = GameData.settings_data['sound'] * 100.0
	sensitivitySlider.value = GameData.settings_data['sensitivity']
	fovSlider.value = GameData.settings_data['fov']
