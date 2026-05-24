extends Node2D
## Constants
const FLASH_SPEED: float = 0.5
const EDGE_MARGIN: float = 40.0

## Editable variables
@export var coordinates:Vector2 = Vector2(0, 0)

## Misc variables
var screenSize:Vector2
var camera:Camera2D

func _ready() -> void:
	screenSize = get_viewport().get_visible_rect().size
	camera = get_tree().get_first_node_in_group("Camera")
	$"Arrived Sprite".modulate.a = 0.5
	
func _process(delta: float) -> void:
	if !camera:
		return
	
	var targetScreenPos: Vector2 = to_local_screen(coordinates)
	var visibleRect := Rect2(Vector2.ZERO, screenSize)
	
	if visibleRect.has_point(targetScreenPos):
		global_position = coordinates
		$Sprite.hide()
		$"Arrived Sprite".rotation = - PI / 2 
		$"Arrived Sprite".show()
		
		
		
	else:
		$"Arrived Sprite".hide()
		$Sprite.show()
		var clampedScreenPos: Vector2 = clamp_to_edge(targetScreenPos)
		global_position = get_viewport().canvas_transform.affine_inverse() * clampedScreenPos
		
		var dir: Vector2 = targetScreenPos - clampedScreenPos
		$Sprite.rotation = dir.angle() + PI

func to_local_screen(worldPos: Vector2) -> Vector2:
	return get_viewport().canvas_transform * worldPos
	
func clamp_to_edge(screen_pos: Vector2) -> Vector2:
	var center: Vector2 = screenSize / 2
	var dir: Vector2 = screen_pos - center
	var half_w: float = center.x - EDGE_MARGIN
	var half_h: float = center.y - EDGE_MARGIN

	# Find how much to scale dir so it just reaches the edge
	var scale_x: float = half_w / abs(dir.x) if dir.x != 0 else INF
	var scale_y: float = half_h / abs(dir.y) if dir.y != 0 else INF
	var scale: float = min(scale_x, scale_y)
	return center + dir * scale
