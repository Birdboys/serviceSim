extends Control

@onready var doorHbox := $doorHbox
@onready var toolIcon := preload("res://scenes/ui/hotbar_icon.tscn")
@onready var equipped_tools 

signal ready_to_leave(yes:bool)

func loadMenu():
	emit_signal("ready_to_leave", GameData.current_gear.any(func(t): return t != ""))
	visible = true
	equipped_tools = GameData.current_gear.duplicate()
	await get_tree().process_frame
	for x in range(len(equipped_tools)):
		var new_icon = toolIcon.instantiate()
		doorHbox.add_child(new_icon, true)
		new_icon.toggleSelected(false)
		new_icon.updateId(x)
		new_icon.gui_input.connect(gearClicked.bind(x))
		if equipped_tools[x] != "": new_icon.updateIcon(equipped_tools[x])
		
func reset():
	for t in doorHbox.get_children(): t.queue_free()
	visible = false
	
func toolClicked(t):
	if t in equipped_tools: return
	AudioHandler.playSound("ui_click")
	for i in range(len(equipped_tools)):
		if equipped_tools[i] == "": 
			equipped_tools[i] = t
			doorHbox.get_child(i).updateIcon(t)
			pushToolData()
			break

func gearClicked(event: InputEvent, i):
	if event is InputEventMouseButton and event.pressed and event.button_index == 1 and equipped_tools[i] != "": 
		AudioHandler.playSound("ui_click")
		equipped_tools[i] = ""
		doorHbox.get_child(i).updateIcon("")
		pushToolData()
	
func pushToolData():
	GameData.current_gear = equipped_tools.duplicate()
	emit_signal("ready_to_leave", GameData.current_gear.any(func(t): return t != ""))
