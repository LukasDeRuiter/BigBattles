extends Control

@onready var container  = $FlowContainer
@onready var cardTemplate = preload("res://Scenes/selection_card.tscn")

func show_units(units):
	clear()
	
	for unit in units:
		var card = cardTemplate.instantiate()
		container.add_child(card)
		card.setup(unit)

func show_building(building):
	clear()
	
	var card = cardTemplate.instantiate()
	container.add_child(card)
	card.setup(building)
	
func clear():
	for child in container.get_children():
		child.queue_free()
