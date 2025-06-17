extends CharacterBody2D

@export var selected = false
@export var move_sounds: Array[AudioStream]
@export var select_sounds: Array[AudioStream]
@export var data: UnitData

@onready var box = get_node("Box")
@onready var animation = get_node("AnimationPlayer")
@onready var sprite = get_node("Sprite")
@onready var move_sound = get_node("MoveSound")
@onready var select_sound = get_node("SelectSound")

var target: Vector2 = Vector2.ZERO
var has_target := false
var follow_cursor = false
var speed = 50
var target_tree: Tree = null
var gathering := false
var gather_timer := 0.0
var gather_rate := 1.0
	
func _ready():
	name = "Unit"
	set_selected(selected)
	add_to_group("units", true)
	target = global_position
	
func set_selected(value):
	selected = value
	box.visible = value

func _input(event):
	if selected:
		if event.is_action_pressed("RightClick"):
			follow_cursor = true
			move_sound.stop()
			
			var all_units = get_tree().get_nodes_in_group("units")
				
			for unit in all_units:
				if unit.selected:
					if unit == self:
						if move_sounds.size() > 0:
							move_sound.stop()
							var index = randi() % move_sounds.size()
							move_sound.stream = move_sounds[index]
							move_sound.play()
					break
				
		if event.is_action_released("RightClick"):
			follow_cursor = false
			move_to(get_global_mouse_position())

func _physics_process(delta):
	if follow_cursor and selected:
			move_to(get_global_mouse_position())
	
	if has_target:
		if global_position.distance_to(target) < 4.0:
			velocity = Vector2.ZERO
			has_target = false
		else:
			var direction = (target - global_position).normalized()
			velocity = direction * speed
	else: 
		velocity = Vector2.ZERO
		
	move_and_slide()
		
	if abs(velocity.x) > abs(velocity.y):
		if velocity.x > 0:
			animation.play("WalkRight")
			sprite.flip_h = false
		else:
			animation.play("WalkRight")
			sprite.flip_h = true
	else:
		animation.play("Idle")
		sprite.flip_h = false
		
func play_select_sound():
	if select_sounds.size() > 0:
		select_sound.stop()
		var index = randi() % select_sounds.size()
		select_sound.stream = select_sounds[index]
		select_sound.play()
	
func set_gather_target(tree: Tree):
	if not data or not data.can_gather_resources:
		print("Unit cannot gather resources")
		return
	
	target_tree = tree
	gathering = true
	gather_timer = 0.0
	move_to(tree.global_position)
	
func move_to(position: Vector2):
	target = position
	has_target = true
