extends "res://Scripts/building.gd"

class_name Farm

var isOccupied = false
var unit: Unit = null

func gather(amount: int):
	var gathered = 1
	
	return gathered

func occupy(occupyingUnit):
	isOccupied = true
	unit = occupyingUnit
	
func unOccupy():
	isOccupied = false
	unit = null
