extends Control

@onready var container = $FlowContainer
@onready var unitDetailsContainer = $SelectionUnitDetails
@onready var cardTemplate = preload("res://Scenes/selection_card.tscn")
@onready var detailsContainer = preload("res://Scenes/selection_details.tscn")

func show_units(units):
	clear()
	
	if units.size() == 1:
		var detailsContainerObject = detailsContainer.instantiate()
		container.add_child(detailsContainerObject)
		detailsContainerObject.setup(units.front())
		detailsContainerObject.visible = true
		
	else:
		for unit in units:
			var card = cardTemplate.instantiate()
			container.add_child(card)
			card.setup(unit)

func show_building(building):
	clear()
	
	var detailsContainerObject = detailsContainer.instantiate()
	container.add_child(detailsContainerObject)
	detailsContainerObject.setup(building)
	detailsContainerObject.visible = true
	
func clear():
	for child in container.get_children():
		child.queue_free()
