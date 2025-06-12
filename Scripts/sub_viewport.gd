extends SubViewport

var tent = preload("res://Scenes/minimap/TentSprite.tscn")
var unit = preload("res://Scenes/minimap/UnitSprite.tscn")
var tree = preload("res://Scenes/minimap/TreeSprite.tscn")

@onready var camera = $Camera

func _ready():
	updateMap()

func updateMap():
	pass
