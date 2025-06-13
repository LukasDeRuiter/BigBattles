extends SubViewport

var tent = preload("res://Scenes/minimap/TentSprite.tscn")
var unit = preload("res://Scenes/minimap/UnitSprite.tscn")
var tree = preload("res://Scenes/minimap/TreeSprite.tscn")

@onready var camera = $Camera

func _ready():
	updateMap()

func updateMap():
	for i in get_child_count() - 3:
		get_child(i + 3).queue_free()
		
	for i in get_node("Units").get_child_count():
		get_node("Units").get_child(i).queue_free()
			
	var buildingsPath = get_tree().get_root().get_node("World/Buildings")
	var unitsPath = get_tree().get_root().get_node("World/Units")
	var objectsPath = get_tree().get_root().get_node("World/Objects")
	
	for i in buildingsPath.get_child_count():
		var building = tent.instantiate()
		add_child(building)
		building.position = buildingsPath.get_child(i).position / 2
		
	for i in unitsPath.get_child_count():
		var unit = unit.instantiate()
		get_node("Units").add_child(unit)
		
	for i in objectsPath.get_child_count():
		var  tree =  tree.instantiate()
		add_child(tree)
		tree.position = objectsPath.get_child(i).position / 2
		

func _process(delta):
	var cameraPath = get_tree().get_root().get_node("World/Camera")
	var unitsPath = get_tree().get_root().get_node("World/Units")
	
	camera.position = cameraPath.position / 2
	camera.zoom = cameraPath.zoom / 2
	
	var unitsTotal = get_node("Units")
	for i in unitsPath.get_child_count():
		unitsTotal.get_child(i).position = unitsPath.get_child(i).position / 2
