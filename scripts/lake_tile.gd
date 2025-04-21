extends TileScene

@onready var lakeBlocker := $lakeBlocker
@onready var lakeTrashScatterer := $lakeTrashScatterer

func _ready() -> void:
	super._ready()
	if GameData.toy_data['floaties']['owned']:
		lakeBlocker.queue_free()

func initTrash():
	await super.initTrash()
	lakeTrashScatterer.num_trash = randi_range(20,40)
	print("DOING LAKE TRASH LMAO")
	lakeTrashScatterer.initTrash()
