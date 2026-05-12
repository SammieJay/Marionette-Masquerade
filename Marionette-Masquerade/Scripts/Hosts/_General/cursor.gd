class_name Cursor
extends Node2D

@onready var inputHandler:InputHandler

const MOUSE_SENSITIVITY:float = 0.1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	inputHandler = get_tree().get_first_node_in_group("InputHandler")
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	global_position = inputHandler.get_mouse_global_position()

