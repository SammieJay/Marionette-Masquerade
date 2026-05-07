## Simple_PlayerController – A simple PlayerControllerSubclass for basic functionality
##
## [b]Responsibilities:[/b] [br]
##   - Act as an example subclass of PlayerController [br]
class_name Simple_PlayerController extends PlayerController

## ===== FUNCTION OVERRIDES =====

func do_player_behavior(_delta:float):
	var moveVector = inputHandler.get_move_input() ## retrieve normalized movement input vector from InputHandler

	# Apply movement
	host.velocity = moveVector * host.moveSpeed * host.MOVE_SPEED_CONSTANT *  _delta
	host.move_and_slide()

	# --- Rotation (face mouse) ---
	var aimPos = inputHandler.get_mouse_global_position()
	var lookDir = (aimPos - host.global_position).normalized()
	var targetDir = lookDir.angle()
	
	#inerpolate towards targetDirection
	host.global_rotation = lerp_angle(host.global_rotation, targetDir, host.rotationSpeed*_delta)

func on_posession()->void:
	pass


## ===== HELPER FUNCTIONS =====