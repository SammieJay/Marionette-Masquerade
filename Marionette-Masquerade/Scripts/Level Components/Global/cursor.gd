class_name Cursor
extends Node2D

@onready var inputHandler:InputHandler
@onready var hostManager:HostManager
@onready var camera:Camera2D

const MOUSE_SENSITIVITY:float = 0.1

var basePosition:Vector2 = Vector2.ZERO
var relativePosition:Vector2 = Vector2.ZERO

var cursorLock:bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	inputHandler = get_tree().get_first_node_in_group("InputHandler")
	hostManager = get_tree().get_first_node_in_group("HostManager")
	camera = get_tree().get_first_node_in_group("Camera")
	
	#global_position = inputHandler.get_mouse_global_position() ## Initial position is set in HostManager class _ready()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:

	if inputHandler.is_action_just_pressed("Toggle Cursor Lock DEBUG"): toggle_cursor_lock() ## Toggle the cursor lock for debug and testing

	if hostManager.playerHost:
		basePosition = camera.global_position
	
	if cursorLock: relativePosition += inputHandler.get_mouse_delta() * GlobalDefs.MOUSE_SENSITIVITY # DELTA NOT NEEDED HERE
	
	# Clamp to visible screen bounds
	var halfSize = get_viewport().get_visible_rect().size / (2.0 * camera.zoom)
	relativePosition = relativePosition.clamp(-halfSize, halfSize)

	global_position = basePosition + relativePosition

	## Update cursor mode for debug purposes
	if cursorLock and Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif !cursorLock and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE) 


func toggle_cursor_lock(): cursorLock = !cursorLock
	

## Places the cursor at the given global position
func set_global_pos(_pos:Vector2):
	relativePosition = _pos - basePosition