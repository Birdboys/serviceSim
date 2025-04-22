extends Control

@onready var mainVbox := $mainVbox
@onready var computerAnim := $computerAnim
@onready var musicSlider := $mainVbox/musicSlider/musicSlider
@onready var soundSlider := $mainVbox/soundSlider/soundSlider
@onready var controlsButton := $mainVbox/controlsButton
@onready var saveButton := $mainVbox/saveButton

@onready var controlsVbox := $controlsVbox
@onready var controlsBack := $controlsVbox/controlsBack

@onready var control_buttons := {
	"forward": $controlsVbox/controlScroll/scrollVbox/forwardCont/forwardButton,
	"back": $controlsVbox/controlScroll/scrollVbox/backwardCont/backwardButton,
	"left": $controlsVbox/controlScroll/scrollVbox/leftCont/leftButton,
	"right": $controlsVbox/controlScroll/scrollVbox/rightCont/rightButton,
	"jump": $controlsVbox/controlScroll/scrollVbox/jumpCont/jumpButton,
	"bag": $controlsVbox/controlScroll/scrollVbox/bagCont/bagButton,
	"call": $controlsVbox/controlScroll/scrollVbox/callCont/callButton,
	"sprint": $controlsVbox/controlScroll/scrollVbox/sprintCont/sprintButton,
	"skate": $controlsVbox/controlScroll/scrollVbox/skateCont/skateButton,
	"music_skip": $controlsVbox/controlScroll/scrollVbox/musicFCont/musicFButton,
	"music_pause": $controlsVbox/controlScroll/scrollVbox/musicPCont/musicPButton,
	"music_rewind": $controlsVbox/controlScroll/scrollVbox/musicRCont/musicRButton,
}

var input_listening := false
var current_control := ""

func _ready() -> void:
	musicSlider.value_changed.connect(updateMusic)
	soundSlider.value_changed.connect(updateSound)
	musicSlider.drag_started.connect(AudioHandler.playSound.bind("ui_click"))
	musicSlider.drag_ended.connect(AudioHandler.playSound.bind("ui_click"))
	soundSlider.drag_started.connect(AudioHandler.playSound.bind("ui_click"))
	soundSlider.drag_ended.connect(AudioHandler.playSound.bind("ui_click"))
	
	controlsButton.pressed.connect(toggleMenu.bind("controls"))
	controlsBack.pressed.connect(toggleMenu.bind("main"))
	saveButton.pressed.connect(saveGame)
	
	for b in control_buttons:
		control_buttons[b].pressed.connect(handleControlButton.bind(b))
	loadButtons()

func _unhandled_input(event: InputEvent) -> void:
	if visible and input_listening and event is InputEventKey:
		if event.keycode == KEY_ESCAPE or event.keycode == KEY_ALT: 
			get_viewport().set_input_as_handled()
			return
		AudioHandler.playSound("ui_click")
		input_listening = false
		updateControl(event)
		
func loadMenu():
	AudioHandler.playSound("computer_sounds")
	setSliders()
	visible = true
	toggleMenu("main")
	computerAnim.play("turn_computer_on")
	
func reset():
	visible = false
	toggleMenu("")

func updateMusic(v):
	GameData.settings_data['music'] = v/100.0
	AudioHandler.loadAudioSettings()
	
func updateSound(v):
	GameData.settings_data['sound'] = v/100.0
	AudioHandler.loadAudioSettings()

func setSliders():
	musicSlider.value = GameData.settings_data['music'] * 100.0
	soundSlider.value = GameData.settings_data['sound'] * 100.0

func toggleMenu(m):
	AudioHandler.playSound("ui_click")
	mainVbox.visible = m == "main"
	controlsVbox.visible = m == "controls"

func saveGame():
	AudioHandler.playSound("ui_click")
	GameData.saveGame()
	computerAnim.play("game_saved")

func handleControlButton(pressed_button: String):
	AudioHandler.playSound("ui_click")
	input_listening = true
	current_control = pressed_button
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	for b in control_buttons:
		if b == pressed_button: 
			control_buttons[b].text = "..."
		else:
			control_buttons[b].text = InputMap.action_get_events(b)[0].as_text().split(" ")[0].to_upper()
		control_buttons[b].button_pressed = b == pressed_button

func loadButtons():
	for b in control_buttons:
		var key_label = InputMap.action_get_events(b)[0].as_text().split(" ")[0].to_upper()
		control_buttons[b].text = key_label

func updateControl(key):
	InputMap.action_erase_events(current_control)
	InputMap.action_add_event(current_control, key)
	control_buttons[current_control].text = InputMap.action_get_events(current_control)[0].as_text().split(" ")[0].to_upper()
	control_buttons[current_control].button_pressed = false
	current_control = ""
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
