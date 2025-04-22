extends Node
@onready var soundQueue := $soundEffectQueue
@onready var soundQueue3D := $soundEffectQueue3D
@onready var bgMusicPlayer := $bgMusicPlayer
@onready var musicUI := $musicUI
@onready var musicAnim := $musicUI/musicAnim
@onready var musicLabel := $musicUI/musicMargin/musicLabel
@onready var players := []
@onready var players_3d := []
@onready var queue_length := 10
@onready var queue_index := 0
@onready var queue_3d_index := 0
@onready var audio_num_vars = {"footstep_grass":4, "footstep_pavement":4, "footstep_rocks":4, "footstep_water":4, "footstep_metal":4, "footstep_bush":2,
"metal_pickup":3, "metal_reject":3, "glass_pickup":1, "glass_reject":3, "plastic_pickup":3, "paper_pickup":1,
"computer_sounds":3, "ui_click":3, "mag_open":3}
@onready var playlist_queue := {
	0: {
		"track": preload("res://assets/music/untitled_kyro.wav"),
		"title": "dots",
		"artist": "Kyro",
	},
	1: {
		"track": preload("res://assets/music/thetallgrass.wav"),
		"title": "the tall grass",
		"artist": "Kyro",
	},
	2: {
		"track": preload("res://assets/music/in_search_of_rocks.mp3"),
		"title": "In Search Of Rocks",
		"artist": "WyzeGye",
	},
	3: {
		"track": preload("res://assets/music/peaks_of_the_horizon.mp3"),
		"title": "Peaks of the Horizon",
		"artist": "WyzeGye",
	},
	4: {
		"track": preload("res://assets/music/oh_girl.mp3"),
		"title": "Oh Girl!",
		"artist": "Esai Vargas",
	},
	5: {
		"track": preload("res://assets/music/the_daze_master.mp3"),
		"title": "Daze",
		"artist": "Esai Vargas",
	},
}

var current_song := 0
var pause_point := 0.0
var music_tween 
func _ready():
	loadAudioSettings()
	populateQueues()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("music_skip") and GameData.toy_data['walkman']['owned']:
		current_song = wrapi(current_song+1, 0, len(playlist_queue))
		changeMusicTrack(current_song)
	elif event.is_action_pressed("music_rewind") and GameData.toy_data['walkman']['owned']:
		current_song = wrapi(current_song-1, 0, len(playlist_queue))
		changeMusicTrack(current_song)
	elif event.is_action_pressed("music_pause") and GameData.toy_data['walkman']['owned']:
		pauseMusicTrack()
		
func populateQueues():
	for x in range(queue_length):
		var new_player = AudioStreamPlayer.new()
		var new_3d_player = AudioStreamPlayer3D.new()
		soundQueue.add_child(new_player)
		soundQueue3D.add_child(new_3d_player)
		new_player.bus = "soundBus"
		new_3d_player.bus = "soundBus"
		players.append(new_player)
		players_3d.append(new_3d_player)
		new_3d_player.finished.connect(reset3DPlayer.bind(x))

func playSound(audio):
	var current_player : AudioStreamPlayer = players[queue_index] 
	queue_index = wrapi(queue_index+1, 0, queue_length-1)
	if current_player.playing: current_player.stop()
	current_player.stream = getAudio(audio)
	current_player.play()
	
func playSound3D(audio, pos: Vector3):
	var current_player : AudioStreamPlayer3D = players_3d[queue_3d_index] 
	queue_3d_index = wrapi(queue_3d_index+1, 0, queue_length-1)
	if current_player.playing: current_player.stop()
	current_player.stream = getAudio(audio)
	current_player.global_position = pos
	current_player.play()
	
func getAudio(audio):
	var audio_name = audio
	if audio_name in audio_num_vars: audio_name = "%s/%s" % [audio_name, randi_range(0, audio_num_vars[audio_name]-1)]
	var sound_stream = load("assets/sounds/%s.wav" % audio_name)
	return sound_stream
	
func setPlayer(player, val):
	match player:
		"music": bgMusicPlayer.volume_db = val

func tweenPlayer(player, val, time=1.0):
	match player:
		"music": 
			if music_tween: music_tween.kill()
			music_tween = get_tree().create_tween()
			music_tween.tween_property(bgMusicPlayer, "volume_db", val, time)
		pass
		
func togglePlayer(player, on):
	match player:
		"music": bgMusicPlayer.playing = on
		pass

func changeMusicTrack(track_id):
	bgMusicPlayer.stream = playlist_queue[track_id]['track']
	bgMusicPlayer.play()
	musicLabel.text = "%s\n%s" % [playlist_queue[track_id]['title'],playlist_queue[track_id]['artist']]
	musicAnim.play("new_track")
	
func pauseMusicTrack():
	if bgMusicPlayer.playing:
		pause_point = bgMusicPlayer.get_playback_position()
		bgMusicPlayer.stop()
	else:
		bgMusicPlayer.play(pause_point)
	
func reset3DPlayer(index):
	players_3d[index].global_position = Vector3.ZERO

func loadAudioSettings():
	AudioServer.set_bus_volume_linear(1, GameData.settings_data['sound'])
	AudioServer.set_bus_volume_linear(2, GameData.settings_data['music'])
	bgMusicPlayer.play()
