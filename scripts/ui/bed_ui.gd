extends CanvasLayer

@onready var escLabel := $UI/uiMargin/escLabel
@onready var menus := {
	"help": $UI/uiMargin/helperMenu,
	"door": $UI/uiMargin/doorMenu,
	"trash": $UI/uiMargin/trashMenu,
	"computer": $UI/uiMargin/computerMenu,
	"table": $UI/uiMargin/tableMenu,
	"tool_mag": $UI/uiMargin/toolMagMenu,
	"toy_mag": $UI/uiMargin/toyMagMenu,
	"poster": $UI/uiMargin/posterMenu,
}

func loadMenu(m):
	if m == "bed": return
	print("LOADING MENU ", m)
	menus[m].loadMenu()
	escLabel.visible = true
	
func reset():
	for m in menus:
		menus[m].reset()

func toolClicked(t):
	menus["door"].toolClicked(t)
