extends VBoxContainer

@onready var colbyRichLabel := $scrollMargin/creditsScroll/scrollVbox/meVbox/colbyRichLabel
@onready var musicRichLabel := $scrollMargin/creditsScroll/scrollVbox/musicVbox/musicRichLabel
@onready var paletteRichLabel := $scrollMargin/creditsScroll/scrollVbox/paletteVbox/paletteRichLabel
@onready var fontsRichLabel := $scrollMargin/creditsScroll/scrollVbox/fontVbox/fontsRichLabel
@onready var modelRichLabel := $scrollMargin/creditsScroll/scrollVbox/modelVbox/modelRichLabel
@onready var wfcRichLabel := $scrollMargin/creditsScroll/scrollVbox/wfcVbox/wfcRichLabel

@onready var labels := [colbyRichLabel, musicRichLabel, paletteRichLabel, fontsRichLabel, modelRichLabel, wfcRichLabel]

func _ready() -> void:
	for l in labels:
		l.meta_clicked.connect(openCreditsLink)
		
func openCreditsLink(link):
	AudioHandler.playSound("ui_click")
	OS.shell_open(str(link))
