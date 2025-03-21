extends CanvasLayer

@onready var menus := {
	"door": $UI/uiMargin/doorMenu,
	"trash": $UI/uiMargin/trashMenu,
	"computer": $UI/uiMargin/computerMenu,
	"table": $UI/uiMargin/tableMenu
}

func loadMenu(m):
	if m == "bed": return
	print("LOADING MENU ", m)
	menus[m].loadMenu()
	
func reset():
	for m in menus:
		menus[m].reset()

func toolClicked(t):
	menus["door"].toolClicked(t)
