extends Button

@export var unit_data: UnitData

var building_reference: Node = null

func _on_presed():
	if building_reference:
		building_reference.queue_train_unit(unit_data)
