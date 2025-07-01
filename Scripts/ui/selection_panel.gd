extends Control

@onready var container  = $FlowContainer
@onready var cardTemplate = preload("res://Scenes/selection_card.tscn")

func show_units(units):
	clear()
	
	for unit in units:
		var card = cardTemplate.instantiate()
		card.setup(unit)
		container.add_child(card)

func show_building(building):
	clear()
	var card = cardTemplate.instantiate()
	card.setup(building)
	container.add_child(card)
	
func clear():
	for child in container.get_children():
		child.queue_free()
