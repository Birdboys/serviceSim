extends TileScene

@onready var lakeBlocker := $lakeBlocker
func _ready() -> void:
	super._ready()
	if GameData.toy_data['floaties']['owned']:
		lakeBlocker.queue_free()
