extends Camera2D

##Controls
@export var SPEED = 30.0
@export var ZOOM_SPEED = 20.0
@export var ZOOM_MARGIN = 0.1
@export var ZOOM_MIN = 0.5
@export var ZOOM_MAX = 3.0

var mousePos = Vector2()
var mousePosGlobal = Vector2()
var start = Vector2()
var startV = Vector2()
var end = Vector2()
var endV = Vector2()
var zoomPosition = Vector2()
var start_global = Vector2()
var end_global = Vector2()

var isDragging = false
var zoomFactor = 1.0
var zooming = false

signal area_selected
signal start_move_selection
signal click_at(position: Vector2)
signal drag_selection(rect: Rect2)

@onready var box = get_node("../UI/Panel")

func _ready():
	var cmd = get_tree().get_root().get_node("World/CommandManager")
	connect("click_at", Callable(cmd, "_on_camera_click"))
	connect("drag_selection", Callable(cmd, "_on_camera_drag"))
	connect("area_selected", Callable(get_parent()	, "_on_area_selected"))

func _process(delta):
	var inputX = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	var inputY = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	
	position.x = lerp(
		position.x, 
		position.x + inputX * SPEED * zoom.x, 
		SPEED * delta
		)
		
	position.y = lerp(
		position.y, 
		position.y + inputY * SPEED * zoom.y, 
		SPEED * delta
		)
		
	zoom.x = lerp(zoom.x, zoom.x * zoomFactor, ZOOM_SPEED * delta)
	zoom.y = lerp(zoom.y, zoom.y * zoomFactor, ZOOM_SPEED * delta)
	
	zoom.x = clamp(zoom.x, ZOOM_MIN, ZOOM_MAX)
	zoom.y = clamp(zoom.y, ZOOM_MIN, ZOOM_MAX)
	
	if not zooming:
		zoomFactor = 1.0
	
	if Input.is_action_just_pressed("LeftClick"):
		start = mousePosGlobal
		startV = mousePos
		isDragging = true
		start_global = get_global_mouse_position()
		
	if isDragging:
		end_global = get_global_mouse_position()
		end = mousePosGlobal
		endV = mousePos
		draw_area()
		
	if Input.is_action_just_released("LeftClick"):
		var drag_dist = start_global.distance_to(end_global)
		
		if drag_dist > 20: 
			var rect = Rect2(start_global, end_global - start_global)
			emit_signal("drag_selection", rect)
		else:
			emit_signal("click_at", end_global)
			
		if startV.distance_to(mousePos) > 20:
			end = mousePosGlobal
			endV = mousePos
			isDragging = false
			draw_area(false)
		else:
			end = start
			isDragging = false
			draw_area(false)

func _input(event):
	if abs(zoomPosition.x - get_global_mouse_position().x) > ZOOM_MARGIN:
		zoomFactor = 1.0 
	if abs(zoomPosition.y - get_global_mouse_position().y) > ZOOM_MARGIN:
		zoomFactor = 1.0 
	
	if event is InputEventMouseButton:
		if event.is_pressed():
			zooming = true
			if event.is_action("WheelDown"):
				zoomFactor -= 0.01 * ZOOM_SPEED
				zoomPosition = get_global_mouse_position()
			if event.is_action("WheelUp"):
				zoomFactor += 0.01 * ZOOM_SPEED
				zoomPosition = get_global_mouse_position()
		else:
			zooming = false
	
	if event is InputEventMouse:
		mousePos = event.position
		mousePosGlobal = get_global_mouse_position()

func draw_area(s = true):
	box.size = Vector2(abs(startV.x - endV.x), abs(startV.y - endV.y))
	var pos = Vector2()
	pos.x = min(startV.x, endV.x)
	pos.y = min(startV.y, endV.y)
	box.position = pos
	box.size *= int(s)
	
	var miniMapPath = get_tree().get_root().get_node("World/UI/MiniMap/SubViewportContainer/SubViewport")
	##miniMapPath._ready()
	
