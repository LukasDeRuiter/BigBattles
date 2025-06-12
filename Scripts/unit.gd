extends CharacterBody2D

@export var selected = false

@onready var box = get_node("Box")
@onready var target = position
@onready var animation = get_node("AnimationPlayer")
@onready var sprite = get_node("Player")

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
