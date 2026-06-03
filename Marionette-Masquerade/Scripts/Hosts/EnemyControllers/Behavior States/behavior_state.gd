## [BehaviorState] – Virtual Base class for state scripts used in enemy behavior FSM
##
## [b]Responsibilities:[/b] [br]
##   - MUST be a child of an EnemyController class in scene tree [br]
##   - Contains reference to EnemyController to call functions like move_to_position [br]
##   - Contains overridatble init_stat() and do_behavior() functions for setup and process functionality [br]
class_name BehaviorState extends Node

## Enum used for the current stus of a behavior state [br]
## Checked every frame by EnemyController class via get_status()
enum BehaviorStatus{INCOMPLETE, SUCCESS, FAILURE, TIMEOUT}

## Script Variables
var enemy:EnemyController
var host:HostController

@export var behaviorName:String = "Unnamed Behavior"


# Called when the node enters the scene tree for the first time.
func _ready():
	enemy = get_parent() as EnemyController
	assert(enemy, "Enemy State %s could not find parent EnemyController" % behaviorName)

	host = enemy.get_parent()
	assert(host, "Enemy State %s could not find parent HostController" % behaviorName)


## ===== VIRTUAL FUNCTIONS =====

## Called every frame that this state is active, does the behavior for this state
func do_behavior(_delta): pass

## Called when entering this state
func on_state_enter(): pass

## Called when exiting this state
func on_state_exit(): pass

## Called every frame, returns current status of the state via enum, returns incomplete by default
func get_status()->BehaviorStatus: return BehaviorStatus.TIMEOUT
