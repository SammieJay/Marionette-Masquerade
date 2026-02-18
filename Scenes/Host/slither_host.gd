extends Host
class_name SlitherHost

@onready var active:bool = false

## MOVEMENT VARIABLES
@export var slither_speed:float = 200.0 #constant forward speed
@export var turn_rate:float = 5.0
@export var summon_distance:float = 100.0

@onready var cursor:Cursor

func _ready():
	possession_animation = $possess_anim
	
	hostManager = get_parent()
	
	cursor = hostManager.cursor
	if cursor == null: printerr("Slither host cannot find cursor from host manager")
	
	alive = false

func _process(delta:float):
	if active: doSlitherMovement(delta)
	
func _input(event) -> void:
	if active:
		if event.is_action_pressed("Transfer Hosts"):
			hostManager.SwitchFromIntermediate()

func doSlitherMovement(delta:float):
	var forward:Vector2 = global_transform.x.normalized()
	var to_target:Vector2 = (cursor.global_position - global_position).normalized()
	
	## Get signed angle difference
	var angle_to_target: float = forward.angle_to(to_target)
	
	var max_turn:float = turn_rate * delta
	angle_to_target = clamp(angle_to_target, -max_turn, max_turn)
	
	global_rotation += angle_to_target
	
	velocity = forward * slither_speed

	move_and_slide()
