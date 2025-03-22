extends Control

@onready var trashLabel := $trashLabel
@onready var moneyLabel := $moneyLabel

func loadMenu():
	visible = true
	trashLabel.text = "Trash Collected: %s pcs" % GameData.total_trash_collected
	moneyLabel.text = "Money Earned: %s" % GameData.total_money 
		
func reset():
	visible = false
