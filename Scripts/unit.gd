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
var target_tree: TreeObject = null
var gathering := false
var gather_timer := 0.0
var gather_rate := 1.0
var can_gather_resources = false
	
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
			gathering = false
			target_tree = null
			
			for object in get_tree().get_nodes_in_group("objects"):
				var chop_area = object.get_node("chopArea") if object.has_node("chopArea") else null
				if chop_area:
					var collision_shape = chop_area.get_node("CollisionShape2D") if chop_area.has_node("CollisionShape2D") else null
					if collision_shape and collision_shape.shape:
						var shape = collision_shape.shape
						var mouse_pos = get_global_mouse_position()
						var global_pos = collision_shape.global_position
						
						if shape is CircleShape2D:
							if global_pos.distance_to(mouse_pos) <= shape.radius:
								set_gather_target(object)
								break
						elif shape is RectangleShape2D:
							# RectangleShape2D is defined by extents from center
							var extents = shape.extents
							# Make a Rect2 with center at global_pos, size = extents * 2
							var rect = Rect2(global_pos - extents, extents * 2)
							if rect.has_point(mouse_pos):
								set_gather_target(object)
								break
						else:
							# fallback: just print warning or skip
							print("Shape type not supported for point check")

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
		
	if gathering and target_tree:
		if global_position.distance_to(target_tree.global_position) < 10.0:
			velocity = Vector2.ZERO
			animation.play("Idle")
			gather_timer += delta
			if gather_timer >= gather_rate:
				gather_timer = 0.0
				collect_wood()
		else:
			move_to(target_tree.global_position)
			
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
	
func set_gather_target(tree: TreeObject):
	if not can_gather_resources:
		print("Unit cannot gather resources")
		return
	
	target_tree = tree
	gathering = true
	gather_timer = 0.0
	move_to(tree.global_position)
	
func move_to(position: Vector2):
	target = position
	has_target = true
	
func collect_wood():
	if not target_tree:
		return
		
	if target_tree.has_method("gather"):
		target_tree.gather(1)
		Game.wood += 1
	else:
		print("Tree cannot be gathered")

	
