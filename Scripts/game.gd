extends Node

@onready var spawn = preload("res://Scenes/spawn_unit.tscn")
@onready var player_class = preload("res://Scenes/player.tscn")
@onready var barbarians_faction_data = preload("res://Data/Factions/Barbarians.tres")

var food = 0
var wood = 0
var gold = 0

var wave = 1
var wave_counter = 0.00

var fps = Engine.get_frames_per_second()

var player: Player
var current_mode: String
var selected_leader: String

func _ready():
	player = player_class.instantiate()
	player.player_id = 1
	player.faction = barbarians_faction_data
