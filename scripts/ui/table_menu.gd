extends Control

@onready var trashLabel := $trashLabel
@onready var moneyLabel := $moneyLabel

func loadMenu():
	visible = true
	moneyLabel.text = "$%s" % GameData.total_money 
		
func reset():
	visible = false
