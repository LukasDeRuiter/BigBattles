extends Resource

class_name UnitData

# General
@export var name: String
@export var description: String
@export var unit_scene: PackedScene
@export var icon: Texture2D
@export var cost: int = 0
@export var train_time: float = 1.5

# Behavior
@export var can_build: bool = false
@export var can_gather_resources: bool = false
@export var can_terraform: bool = false

# Combat
@export var is_combat_unit: bool
@export var health: int
@export var attack_damage: int
@export var attack_range: float
@export var attack_cooldown: float
@export var is_ranged_unit: bool
@export var projectile_scene: PackedScene
@export var projectile_speed: float
