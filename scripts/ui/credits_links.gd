extends VBoxContainer

@onready var colbyRichLabel := $scrollMargin/creditsScroll/scrollVbox/meVbox/colbyRichLabel
@onready var paletteRichLabel := $scrollMargin/creditsScroll/scrollVbox/paletteVbox/paletteRichLabel
@onready var fontsRichLabel := $scrollMargin/creditsScroll/scrollVbox/fontVbox/fontsRichLabel


@onready var labels := [colbyRichLabel, paletteRichLabel, fontsRichLabel]

func _ready() -> void:
	for l in labels:
		l.meta_clicked.connect(openCreditsLink)
		
func openCreditsLink(link):
	OS.shell_open(str(link))
