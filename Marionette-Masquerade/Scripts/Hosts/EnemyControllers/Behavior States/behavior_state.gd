## [BehaviorState] – Base class for state machine state scripts
##
## [b]Responsibilities:[/b] [br]
##   - Contains reference to EnemyController to call functions like move_to_position [br]
##   - Contains overridatble init_stat() and do_behavior() functions for setup and process functionality [br]
class_name BehaviorState extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
