extends Node3D

@onready var roadTile := $roadLTile
@onready var uiAnim := $titleUI/uiAnim
@onready var settingsVbox := $titleUI/titleMargin/settingsVbox
@onready var buttonVbox := $titleUI/titleMargin/buttonVbox
@onready var creditsVbox := $titleUI/titleMargin/creditsVbox

@onready var playButton := $titleUI/titleMargin/buttonVbox/playButton
@onready var settingsButton := $titleUI/titleMargin/buttonVbox/settingsButton
@onready var settingsBack := $titleUI/titleMargin/settingsVbox/backButton
@onready var creditsButton := $titleUI/titleMargin/buttonVbox/creditsButton
@onready var creditsBack := $titleUI/titleMargin/creditsVbox/backButton
@onready var quitButton := $titleUI/titleMargin/buttonVbox/quitButton
@onready var resetButton := $titleUI/titleMargin/resetButton

@onready var musicSlider := $titleUI/titleMargin/settingsVbox/mainVbox/musicSlider/musicSlider
@onready var soundSlider := $titleUI/titleMargin/settingsVbox/mainVbox/soundSlider/soundSlider

var current_menu := "main"

func _ready() -> void:
	
	playButton.pressed.connect(toBed)
	settingsButton.pressed.connect(loadMenu.bind("settings"))
	settingsBack.pressed.connect(loadMenu.bind("main"))
	creditsButton.pressed.connect(loadMenu.bind("credits"))
	creditsBack.pressed.connect(loadMenu.bind("main"))
	resetButton.pressed.connect(resetSaveData)
	resetButton.mouse_entered.connect(toggleResetButton.bind(true))
	resetButton.mouse_exited.connect(toggleResetButton.bind(false))
	quitButton.pressed.connect(get_tree().quit)
	
	musicSlider.value_changed.connect(updateMusic)
	soundSlider.value_changed.connect(updateSound)
	
	loadTitle()
	
func loadTitle():
	uiAnim.play("RESET")
	loadMenu("main")
	await roadTile.initTrash()
	uiAnim.play("load_menu")
	await uiAnim.animation_finished
	uiAnim.play("idle_menu")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("escape"): loadMenu("main")
	elif event is InputEventKey and event.keycode == KEY_F5 and event.pressed and uiAnim.current_animation == "idle_menu": 
		print("TRYING RELOAD")
		get_tree().reload_current_scene()
	
func loadMenu(m: String):
	current_menu = m
	match m:
		"main":
			buttonVbox.visible = true
			settingsVbox.visible = false
			creditsVbox.visible = false
		"settings":
			setSliders()
			settingsVbox.visible = true
			buttonVbox.visible = false
		"credits":
			creditsVbox.visible = true
			buttonVbox.visible = false
	
func updateMusic(v):
	GameData.settings_data['music'] = v/100.0
	AudioHandler.loadAudioSettings()
	
func updateSound(v):
	GameData.settings_data['sound'] = v/100.0
	AudioHandler.loadAudioSettings()

func setSliders():
	musicSlider.value = GameData.settings_data['music'] * 100.0
	soundSlider.value = GameData.settings_data['sound'] * 100.0

func toBed():
	uiAnim.play("to_bed")
	await uiAnim.animation_finished
	get_tree().change_scene_to_file("res://scenes/bed_menu.tscn")

func toggleResetButton(on: bool):
	if on: resetButton.text = "CLICK TO PERMANENTLY RESET SAVE"
	else: resetButton.text = "RESET"

func resetSaveData():
	print("RESET THE GAMEERTONDSA")
	await GameData.resetSaveData()
	get_tree().reload_current_scene()
