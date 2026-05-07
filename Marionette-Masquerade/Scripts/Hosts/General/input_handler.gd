## [InputHandler] – SINGLETON CLASS: listens for player input durring gameplay, required in every gameplay scene
##
## [b]Responsibilities:[/b] [br]
##   - listen for player input and format it into easily interpretable forms (look direction delta, move direction, etc) [br]
##   - acessible via a group with only the input handler within in [br]
class_name InputHandler extends Node2D



## ===== SCRIPT VARIABLES =====

var mouseDelta: Vector2 = Vector2.ZERO ## The change in mouse position since the last frame (updated every frame)


## ===== MAIN FUNCTIONS =====

func _input(event: InputEvent)->void:
	if event is InputEventMouseMotion: mouseDelta = event.relative


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta): 
	mouseDelta = Vector2.ZERO # Reset mouse delta each frame (probably called before input event)


## ===== MOUSE FUNCTIONS =====

func get_mouse_delta()->Vector2: return mouseDelta ## Returns change in mouse position since last frame as Vector2

func get_mouse_screen_position()->Vector2: return get_viewport().get_mouse_position() ## Returns the current screenspace coordinates of the mouse

func get_mouse_global_position()->Vector2: return get_global_mouse_position()


## ===== GENERIC INPUT RETURNS =====

## Returns movement input direction as a Vector2
func get_move_input()->Vector2:
	return Input.get_vector("Move Left", "Move Right", "Move Up", "Move Down").normalized()

func is_action_pressed(_action: StringName) -> bool:
	return Input.is_action_pressed(_action)

func is_action_just_pressed(_action: StringName) -> bool:
	return Input.is_action_just_pressed(_action)

func is_action_just_released(_action: StringName) -> bool:
	return Input.is_action_just_released(_action)
