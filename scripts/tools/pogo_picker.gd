extends TrashTool

enum pogo_states {IDLE, READY, BOUNCING, FALLING}

@onready var pickerAnim := $pickerAnim
@onready var pickerMesh := $pickerMesh
@onready var trashArea := $trashArea
@onready var bounceArea := $bounceArea
@export var state := pogo_states.IDLE

var bounce_strength := 10.0
var current_height := 0.0
var prev_height := 0.0
var player_pos 
signal pogo_jump

func _ready() -> void:
	trashArea.area_entered.connect(collectTrash)
	bounceArea.body_entered.connect(pogoJump)

func _physics_process(delta: float) -> void:
	prev_height = current_height
	current_height = player_pos.global_position.y
	match state:
		pogo_states.READY, pogo_states.BOUNCING:
			if current_height < prev_height:
				state = pogo_states.FALLING
				
func primaryDown():
	match state:
		pogo_states.IDLE:
			pickerAnim.play("ready")

func primaryUp():
	pickerAnim.play_backwards("ready")

func collectTrash(t):
	print("COLLECTING TRASH")
	if t is TrashBox and isTrashValid(t.get_parent()) and state == pogo_states.FALLING:
		emit_signal("attempt_collect_trash", t.get_parent())
		emit_signal("pogo_jump", bounce_strength+5)
		state = pogo_states.BOUNCING

func pogoJump(_ground):
	match state:
		pogo_states.FALLING:
			emit_signal("pogo_jump", bounce_strength)
			state = pogo_states.BOUNCING
			
func equip():
	player_pos = get_parent().get_parent().get_parent()
	print(player_pos, player_pos.name)
	prev_height = player_pos.global_position.y
	current_height = player_pos.global_position.y
	
	trashArea.reparent(player_pos)
	trashArea.position = Vector3(0.0, -1.75, 0.0)
	bounceArea.reparent(player_pos)
	bounceArea.position = Vector3(0.0, -1.75, 0.0)
