## [EnemyController] – Abstract class that acts as a controller for all enemy behavior of this host type
##
## [b]Responsibilities:[/b] [br]
##   - Child classes perform state machine oversight (state transition logic) [br]
##   - Contains functions for general AI behavior like movement [br]
##   - Is inherited to make an enemy controller specific to each host type [br]
##   - Retrieves references to other nodes via the HostController [br]
class_name EnemyController extends Node

## ===== EXPORT VARIABLES =====
@export_category("References")
@export_group("REQUIRED")
@export var navAgent:NavigationAgent2D

@export_category("Enemy Propperties")
@export var confusionDelayTime:float = 1.0 ## How long this host takes to target the player after they switch hosts
@export var postPossessionStunTime:float = 3.0 ## How long this host is stunned after player switches to anoter host
@export_range(0.0, 3.0, 0.1, "scaled from host speed") var enemyMoveSpeedScalar:float = 1.0

@export_category("DEBUG")
@export var disableAI:bool = false


## ===== SCRIPT VARIABLES =====
# ----- References -----
var host:HostController
var weapon:Weapon

# ----- State Machine -----
var activeState:BehaviorState

## A pointer towards the host that this enemy is hostile to, should be set by subclasses in their _process() functions
var targetHost:HostController

# ----- Confusion -----
var confusionTimer:float = 0.0

# ----- Stunned -----
var stunnedTimer:float = 0.0

# ----- Navigation -----
var navTargetPos:Vector2 = Vector2.ZERO ## If navTargetPos == Vector2.ZERO, then enemy will not move
var navTargetHost:HostController ## If navTargetHost == null, then enemy will not move, otherwise will path towards current target host position (supercedes navTargetPos)

const DEFAULT_NAV_DIST: float = 20.0 ## Default distance enemy will get to target position before stopping (alternative can be provided)
var navTargetDist:float = DEFAULT_NAV_DIST ## How far the enemy should be from the target before it stops moving


## ===== BOOLEAN RETURNS =====

func is_confused()->bool: return confusionTimer > 0.0
func is_stunned()->bool: return stunnedTimer > 0.0
func is_moving()->bool:return navTargetPos != Vector2.ZERO or navTargetHost != null ## Returns true if enemy is attempting to move towards a pathfinding target (position or host)


## ===== CORE FUNCTIONS =====

## MUST BE CALLED FROM INHERITING CLASSES VIA 'super._ready()' [br]
## Ticks important timers each frame
func _process(_delta):
	## Update Timers
	if confusionTimer >= 0.0: confusionTimer -= _delta
	if stunnedTimer >= 0.0: stunnedTimer -= _delta

func _physics_process(_delta):
	if !host.is_possessed():
		update_movement(_delta) ## Do enemy movement
	elif is_moving(): halt_movement() # interrupt movement if host becomes posessed

## updates movement of enemy every physics frame [br]
## called from _physics process [br]
func update_movement(_delta:float):
	# update target position as navTargetHost position if avaliable
	if navTargetHost != null: navTargetPos = navTargetHost.global_position # if navTargetHost != null -> path to targetHost (this overrides navTargetPos)

	# update position of target host (if target host is no longer at the same position)
	if navAgent.target_position != navTargetPos and is_moving(): navAgent.target_position = navTargetPos

	var distToTarget = host.global_position.distance_to(navTargetPos)

	## APPLY MOVEMENT UPDATE IF WE ARE NOT CLOSE ENOUGH TO TARGET
	if is_moving() and distToTarget > navTargetDist: #if enemy wants to move, do movement code
		var nextPos = navAgent.get_next_path_position()
		var dir = (nextPos - host.global_position).normalized()
		host.velocity = dir * host.moveSpeed * host.MOVE_SPEED_CONST * _delta
		_lerp_look_at_pos(_delta, nextPos)
		host.move_and_slide()
	elif is_moving(): halt_movement() # terminate movement when desired distance is reached


## ===== STATE MACHINE FUNCTIONS =====

## Called by inheriting classes to set the active behavior state of this enemy
func set_active_state(_next:BehaviorState):
	if activeState == _next: return
	
	if activeState: print("Leaving State: ", activeState.name)
	print("Entering State: ", _next.name)

	if activeState: activeState.on_state_exit() ## If there is currently an active state, call its exit function
	activeState = _next
	activeState.on_state_enter()


## ===== MOVEMENT FUNCTIONS FOR STATE MACHINE TO CALL =====

## Move within _targetDist units of given position _pos
func path_to_position(_pos:Vector2, _targetDist:float = DEFAULT_NAV_DIST)->void:
	navTargetPos = _pos
	navTargetDist = _targetDist

## Continuously path towards given [HostController] _host, until we are within _targetDist units
func path_to_host(_host:HostController, _targetDist:float = DEFAULT_NAV_DIST):
	navTargetHost = _host
	navTargetDist = _targetDist

## Simply Clears Navigation Targets, Host Will Stop Moving Immediately
func halt_movement():
	navTargetPos = Vector2.ZERO
	navTargetHost = null


## ===== VIRTUAL FUNCTIONS TO BE OVERRIDEN =====

## [b]VIRTUAL[/b][br]
## Called: By HostController every frame that host is not possessed [br]
## Handles: State machine BehaviorState transitions and enemy thinking [br]
func do_enemy_behavior(_delta:float): pass

## [b]VIRTUAL[/b][br]
## Called: By HostController every PHYSICS frame that host is not possessed [br]
## Handles: State machine BehaviorState transitions and enemy thinking [br]
func do_enemy_physics(_delta:float): pass

## [b]VIRTUAL[/b][br]
## Called: By HostController when player leaves this host [br]
## Handles: Effects and behavior when possession is released [br]
func on_possession_release()->void: pass




## ===== HELPER FUNCTIONS =====

## Verify if required references are present in host
func _verify_refrences()->void:
	assert(navAgent != null, "EnemyController for %s is missing reference to required NavigationAgent2D" % host.hostTypeName)

## Interpolate host rotation to look towards the given position in world space (global_position)
func _lerp_look_at_pos(_delta:float, _pos:Vector2):
	print("Looking to: ", _pos)
	var dir = (_pos - host.global_position).normalized()
	host.global_rotation = lerp_angle(host.global_rotation, dir.angle(), host.rotationSpeed * _delta)

## Interpolate host rotation towards given angle (in radians)
func _lerp_look_to_angle(_delta:float, _angle:float):
	host.global_rotation = lerp_angle(host.global_rotation, _angle, host.rotationSpeed * _delta)
