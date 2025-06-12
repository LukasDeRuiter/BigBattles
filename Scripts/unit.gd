extends CharacterBody2D

@export var selected = false
@export var move_sounds: Array[AudioStream]
@export var select_sounds: Array[AudioStream]

@onready var box = get_node("Box")
@onready var target = position
@onready var animation = get_node("AnimationPlayer")
@onready var sprite = get_node("Player")
@onready var move_sound = get_node("MoveSound")
@onready var select_sound = get_node("SelectSound")

var follow_cursor = false
var speed = 50
	
func _ready():
	name = "Unit"
	set_selected(selected)
	add_to_group("units", true)
	
func set_selected(value):
	selected = value
	box.visible = value

func _input(event):
	if event.is_action_pressed("RightClick"):
		follow_cursor = true
		
		if selected:
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

func _physics_process(delta):
	if follow_cursor == true:
		if selected:
			target = get_global_mouse_position()
			
	velocity = position.direction_to(target) * speed
	
	if position.distance_to(target) > 10:
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
	
