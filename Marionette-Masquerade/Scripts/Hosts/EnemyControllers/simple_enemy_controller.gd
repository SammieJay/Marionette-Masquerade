## [SimpleEnemyController] – A simple override of the EnemyController, uses repurposed Host code from GGJ version
##
## [b]Responsibilities:[/b] [br]
##   - Override do_enemy_behavior() function [br]
##   - Use state machine to control enemy thinking [br]
class_name SimpleEnemy extends EnemyController


## ===== EXPORT VARIABLES =====
@export_category("STATE MACHINE")
@export var idleState:BehaviorState
@export var chaseState:BehaviorState

@export_category("Host Properties")
@export_range(0.0, 10.0, 0.25, "Stun Durration Post Swap") var stunDurration:float = 1.5 ## How long this host is stunned for after swap, setting to 0 disables stun mechanic


## ===== SCRIPT VARIABLES =====
# Idle
var idleTimer := 0.0
var idleLookTarget:float = 0.0


# Called when the node enters the scene tree for the first time.
func _ready():
	assert(idleState, "Enemy %s has no reference to required Idle State BehaviorState node" %name)
	assert(chaseState, "Enemy %s has no reference to required Chase State BehaviorState node" %name)

	## Set default state
	set_active_state(idleState)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	super._process(_delta) ## Required call to parent _process() function (updates important timers)

func do_enemy_behavior(_delta:float):
	if !is_stunned():
		activeState.do_behavior(_delta) # update active state behavior


	## ===== STATE TRANSITIONS =====

	## Do state transitions depending on current status of the active state
	var stateStatus:BehaviorState.BehaviorStatus = activeState.get_status()

	match activeState:
		idleState:
			match stateStatus:
				BehaviorState.BehaviorStatus.INCOMPLETE: pass
				BehaviorState.BehaviorStatus.SUCCESS:
					if targetHost and targetHost.is_alive():
						set_active_state(chaseState)
					else: pass
		chaseState:
			match stateStatus:
				BehaviorState.BehaviorStatus.INCOMPLETE: pass
				BehaviorState.BehaviorStatus.SUCCESS: set_active_state(idleState)



func on_possession_release()->void: stun(stunDurration)
