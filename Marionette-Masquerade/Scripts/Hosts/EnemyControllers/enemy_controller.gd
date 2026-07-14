## [EnemyController] – Abstract class that acts as a controller for all enemy behavior of this host type
##
## [b]Responsibilities:[/b] [br]
##   - Child classes perform state machine oversight (state transition logic) [br]
##   - Contains functions for general AI behavior like movement [br]
##   - Is inherited to make an enemy controller specific to each host type [br]
##   - Retrieves references to other nodes via the HostController [br]
class_name EnemyController extends Node

enum EnemyState {
	DEFAULT, 	## Enemy is opperating as normal and doing enemy behavior normally
	PHYSICS,	## Enemy is unable to move or shoot of their own will, but can be posessed
	STUN		## Enemy is unable to move, shoot, or be posessed
}

## ===== EXPORT VARIABLES =====
@export_category("References")
@export_group("REQUIRED")
@export var navAgent:NavigationAgent2D

@export_category("Enemy Propperties")
@export var confusionDelayTime:float = 1.2 ## How long this host takes to target the player after they switch hosts
@export var postPossessionStunTime:float = 3.0 ## How long this host is stunned after player switches to anoter host
@export_range(0.0, 3.0, 0.1, "scaled from host speed") var enemyMoveSpeedScalar:float = 1.0

@export_category("Physics")
@export var impulseDamping:float = 2.0 ## How aggressively the host slows down after an impulse is applied
@export var reboundForce:float = 0.25
@export var takeDmgOnCollide:bool = true
@export var collisionStunThreshold:float = 200.0
@export var minPhysicsVelocity:float = 1.0

## ===== SIGNALS =====
signal collision(_force:float, _col:KinematicCollision2D, _dir:Vector2) ## Signal emits when host collides with something, signal includes colision information and the force / direction of the collision


## ===== SCRIPT VARIABLES =====
# ----- References -----
var host:HostController
var weapon:Weapon
var inputHandler:InputHandler
var cursor:Cursor

# ----- State Machine -----
var activeState:BehaviorState

# ----- Enemy State ----- 
var enemyState:EnemyState = EnemyState.DEFAULT

# ----- Stunned -----
var stunnedTimer:float = 0.0


# ----- Navigation -----
var navTargetPos:Vector2 = Vector2.ZERO ## If navTargetPos == Vector2.ZERO, then enemy will not move
var navTargetHost:HostController ## If navTargetHost == null, then enemy will not move, otherwise will path towards current target host position (supercedes navTargetPos)

const DEFAULT_NAV_DIST: float = 20.0 ## Default distance enemy will get to target position before stopping (alternative can be provided)
var navTargetDist:float = DEFAULT_NAV_DIST ## How far the enemy should be from the target before it stops moving

# ----- Targetting -----
var confusionTimer:float = 0.0
var hostHistoryIdx:int = -1
var targetHost:HostController ## A pointer towards the host that this enemy is hostile to, should be set by subclasses in their _process() functions

# ----- Physics -----
var physicsVelocity:Vector2 = Vector2.ZERO
var sinceLastImpact:float = 0.0
var forcePhysicsState:bool = false ## When true, enemy is forced into physics enemyState

## ===== BOOLEAN RETURNS =====

func is_confused()->bool: return confusionTimer > 0.0
func is_stunned()->bool: return stunnedTimer > 0.0
func is_moving()->bool:return navTargetPos != Vector2.ZERO or navTargetHost != null ## Returns true if enemy is attempting to move towards a pathfinding target (position or host)
func is_enemyState(_state:EnemyState)->bool: return _state == enemyState

## ===== ENEMY STATE MACHINE FUNCTIONS ======
func set_enemy_state(_next:EnemyState):
	if is_enemyState(_next): return ## If state is already set to _next, just return
	
	## CODE THAT RUNS WHEN EXITING A STATE
	match enemyState:
		EnemyState.DEFAULT:
			if is_moving(): halt_movement()
		EnemyState.STUN:
			host.effectHandler.set_stun(false)
		EnemyState.PHYSICS:
			pass
	
	enemyState = _next

	## CODE THAT RUNS WHEN ENTERING A STATE
	match enemyState:
		EnemyState.DEFAULT:
			host.currentlyPossesable = true
		EnemyState.STUN:
			host.currentlyPossesable = false
			host.effectHandler.set_stun(true)
		EnemyState.PHYSICS:
			host.currentlyPossesable = true

## ===== CORE FUNCTIONS =====

## Process function for the enemy controller specific functionality [br]
## Called by HostController every frame when enemy is posessed
func _enemy_process(_delta:float):
	## Update Timers
	if confusionTimer > 0.0: confusionTimer -= _delta

	_update_confusion_target()
	
	## ENEMYSTATE DEPENDANT UPDATES
	match enemyState:
		EnemyState.DEFAULT:
			do_enemy_behavior(_delta)
		EnemyState.PHYSICS:
			pass
		EnemyState.STUN:
			stunnedTimer -= _delta
			if stunnedTimer <= 0.0: set_enemy_state(EnemyState.DEFAULT) ## Leave Stunned State

## Process function for the enemy controller specific functionality [br]
## Called by HostController every physics frame when enemy is posessed
func _enemy_physics_process(_delta):
	if forcePhysicsState: set_enemy_state(EnemyState.PHYSICS)
	
	match enemyState:
		EnemyState.DEFAULT:
			do_enemy_physics(_delta)
			update_movement(_delta) ## Do enemy movement
		EnemyState.PHYSICS:
			## Physics Handling
			sinceLastImpact += _delta
	
			if physicsVelocity.length() < minPhysicsVelocity and !forcePhysicsState:
				set_enemy_state(EnemyState.DEFAULT) ## switch state
				return
			
			update_physics(_delta)
		EnemyState.STUN:
			pass


## Updates the physics response of the enemy if in physics mode[br]
## Called from _physics_process()
func update_physics(_delta:float):
	if host.is_possessable(): host.currentlyPossesable = false

	host.velocity = physicsVelocity
	physicsVelocity = physicsVelocity.lerp(Vector2.ZERO, impulseDamping * _delta)
	
	var beforeVel:= host.velocity
	host.move_and_slide()
	_check_collisions(_delta, beforeVel)

## updates movement of enemy every physics frame [br]
## called from _physics_process [br]
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
		host.velocity = dir * host.moveSpeed * GlobalDefs.MOVE_SPEED_CONST * _delta
		_lerp_look_at_pos(_delta, nextPos)
		host.move_and_slide()
	elif is_moving(): halt_movement() # terminate movement when desired distance is reached

## Called: By HostController when player leaves this host [br]
## Handles: Effects and behavior when possession is released [br]
## Can be overriden but must be called via super.on_possession_release() to perform this functionality
func on_possession_release()->void:
	if postPossessionStunTime > 0.0:
		stun(postPossessionStunTime)
	else: set_enemy_state(EnemyState.DEFAULT)

## [b]VIRTUAL[/b][br]
## Called: By HostController when player enters this host [br]
## Handles: Effects and behavior when enemy becomes posesssed
func on_possession()->void: pass


func stun(_durration:float):
	stunnedTimer = _durration
	set_enemy_state(EnemyState.STUN)

## Advances [member targetHost] through the HostManager possession history one step per [member confusionDelayTime]. [br]
## Tracks an explicit index into the history array so duplicate host entries are handled correctly. [br]
## Dead hosts in the chain are skipped without delay.
func _update_confusion_target() -> void:
	if !host or !host.hostManager: return

	var history := host.hostManager.possessionHistory
	if history.is_empty(): return

	var latestIdx := history.size() - 1

	## Initialise on first run — snap straight to the current player host
	if hostHistoryIdx < 0:
		hostHistoryIdx = latestIdx
		targetHost = history[hostHistoryIdx]
		confusionTimer = 0.0
		return

	## Already at the front of history — keep targetHost in sync and do nothing
	if hostHistoryIdx >= latestIdx:
		targetHost = history[latestIdx]
		confusionTimer = 0.0
		return

	## We are behind the latest entry — begin or continue catching up
	if confusionTimer == 0.0:
		## Peek ahead: skip any immediately dead hosts so no delay is wasted on corpses
		var peekIdx := hostHistoryIdx + 1
		while peekIdx <= latestIdx and !history[peekIdx].is_alive():
			peekIdx += 1

		if peekIdx > latestIdx:
			## Everything ahead is dead — snap to the latest entry
			hostHistoryIdx = latestIdx
			targetHost = history[hostHistoryIdx]
			return

		## Start the confusion delay; enemy keeps targeting its current host until it expires
		confusionTimer = confusionDelayTime

	elif confusionTimer <= 0.0:
		## Delay expired — step forward by one index
		confusionTimer = 0.0
		hostHistoryIdx += 1

		## Skip any dead hosts at the new position without further delay
		while hostHistoryIdx < latestIdx and !history[hostHistoryIdx].is_alive():
			hostHistoryIdx += 1

		targetHost = history[hostHistoryIdx]
		## If hostHistoryIdx is still behind latestIdx, the next call will
		## detect the gap and start a fresh confusion delay for the next hop




## ===== BEHAVIOR STATE MACHINE FUNCTIONS =====

## Called by inheriting classes to set the active behavior state of this enemy
func set_behavior_state(_next:BehaviorState):
	if activeState == _next: return
	
	#if activeState: print("Leaving State: ", activeState.name)
	#print("Entering State: ", _next.name)

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
## Called: By EnemyController every frame that host is not possessed [br]
## Handles: State machine BehaviorState transitions and enemy thinking [br]
func do_enemy_behavior(_delta:float): pass

## [b]VIRTUAL[/b][br]
## Called: By EnemyController every PHYSICS frame that host is not possessed [br]
## Handles: State machine BehaviorState transitions and enemy thinking [br]
func do_enemy_physics(_delta:float): pass



## [b]VIRTUAL[/b][br]
## Called: By EnemyController class when an impact occurs, passes important impact data [br]
## Handles: Custom collision response by subclasses [br]
func on_impact(_force:float, _col:KinematicCollision2D, _lastVel:Vector2): pass


## ===== PHYSICS FUNCTIONS =====

## Called from update_physics() when in physics mode, to check for colisions
func _check_collisions(_delta:float, _lastFrameVel:Vector2):
	for i in host.get_slide_collision_count():
		var col:KinematicCollision2D = host.get_slide_collision(i)
		var normal:Vector2 = col.get_normal()
		
		var impact_speed:float = abs(_lastFrameVel.dot(normal))
		#print("IMPACT: ", impact_speed)
		
		
		if sinceLastImpact > 0.15 and impact_speed > 100.0:
			impact_response(impact_speed, col, _lastFrameVel)

## Called from _check_collisions() if an impact is detected
func impact_response(_force:float, _col:KinematicCollision2D, _lastVel:Vector2):
	collision.emit(_force, _col, _lastVel.normalized()) ## Emmit colision signal with relevent information
	
	var reflectionDir:Vector2 = _lastVel.bounce(_col.get_normal())

	physicsVelocity = reflectionDir.normalized()*_force * reboundForce
	sinceLastImpact = 0.0

	var colDmg:float = snappedf(_force * 0.002, 0.1) ## damage of collision (scaled down and rounded)
	if takeDmgOnCollide:
		
		host.hurt(colDmg)
	
	## STUN
	if host.is_alive(): stun(2.0)
	var other := _col.get_collider()
	if other is HostController:
		var otherHost:HostController = other as HostController
		if !otherHost.is_possessed():
			otherHost.enemyController.stun(2.0)
			otherHost.hurt(colDmg/2.0)
		


func give_impulse(_force:Vector2):
	physicsVelocity += _force


## ===== HELPER FUNCTIONS =====

## Verify if required references are present in host
func _verify_refrences()->void:
	assert(navAgent != null, "EnemyController for %s is missing reference to required NavigationAgent2D" % host.hostTypeName)

## Interpolate host rotation to look towards the given position in world space (global_position)
func _lerp_look_at_pos(_delta:float, _pos:Vector2):
	#print("Looking to: ", _pos)
	var dir = (_pos - host.global_position).normalized()
	host.global_rotation = lerp_angle(host.global_rotation, dir.angle(), host.rotationSpeed * _delta)

## Interpolate host rotation towards given angle (in radians)
func _lerp_look_to_angle(_delta:float, _angle:float):
	host.global_rotation = lerp_angle(host.global_rotation, _angle, host.rotationSpeed * _delta)



