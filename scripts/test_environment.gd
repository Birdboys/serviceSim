extends Node3D

@onready var player := $playerCharacter

var start_time
var round_time := 10 * 60.0 + 1

func _ready() -> void:
	start_time = Time.get_ticks_msec()

func _physics_process(delta: float) -> void:
	var elapsed_time = int(Time.get_ticks_msec()/1000)
	player.UI.updateTimerLabel(round_time - elapsed_time)
