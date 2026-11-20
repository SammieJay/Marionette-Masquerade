## [BasicPlayerMotor] – [Motor] class override that computes the movement and rotation for a host using player input
##
## [b]Responsibilities:[/b] [br]
##   - Contains a reference to the input handler
##	 - Returns the next look direction and position of the player to the HostController
class_name BasicPlayerMotor extends Motor

@export_group("Movement Settings")
@export var moveSpeed:float = 20.0
@export var rotationSpeed:float = 7.0

@onready var inputHandler:InputHandler
@onready var cursor:Cursor

var moveSpeedMultiplier:float = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	inputHandler = get_tree().get_first_node_in_group("InputHandler")
	cursor = get_tree().get_first_node_in_group("Cursor")

	assert(body!=null, "PlayerMotor has not been given reference to Host body")

func compute_velocity(_delta:float) -> Vector2:
	var moveVector = inputHandler.get_move_input() ## retrieve normalized movement input vector from InputHandler
	return moveVector * moveSpeed * GlobalDefs.MOVE_SPEED_CONST * _delta

func compute_rotation(_delta:float) -> float:
	# --- Rotation (face mouse) ---
	var aimPos = cursor.global_position
	var lookDir = (aimPos - body.global_position).normalized()
	var targetDir = lookDir.angle()
	
	#inerpolate towards targetDirection
	return lerp_angle(body.global_rotation, targetDir, rotationSpeed*_delta)