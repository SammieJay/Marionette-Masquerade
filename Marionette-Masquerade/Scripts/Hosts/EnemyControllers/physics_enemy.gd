## [PhysicsEnemy] – A simple override of the EnemyController, uses repurposed Host code from GGJ version
##
## [b]Responsibilities:[/b] [br]
##   - Override do_enemy_behavior() function [br]
##   - Use state machine to control enemy thinking [br]
class_name PhysicsEnemy extends EnemyController


## ===== EXPORT VARIABLES =====
@export_category("STATE MACHINE")
@export var idleState:BehaviorState
@export var chaseState:BehaviorState

@export_category("Host Properties")
@export_range(0.0, 10.0, 0.25, "Stun Durration Post Swap") var stunDurration:float = 1.5 ## How long this host is stunned for after swap, setting to 0 disables stun mechanic

@export_category("Physics")
@export var impulseDamping:float = 2.0 ## How aggressively the host slows down after an impulse is applied
@export var reboundForce:float = 0.25
@export var takeDmgOnCollide:bool = true
@export var collisionStunThreshold:float = 200.0
@export var minPhysicsVelocity:float = 1.0

# ----- Physics -----
@onready var physicsVelocity:Vector2 = Vector2.ZERO

## ===== SCRIPT VARIABLES =====
# Idle
var idleTimer := 0.0
var idleLookTarget:float = 0.0

var grabbed:bool = false
var physicsMode:bool = false ## If true, AI is disabled and enemy acts as a rigidbody
var grabberHost:HostController = null
@onready var cursor:Cursor
@onready var inputHandler:InputHandler

var sinceLastImpact:float = 0.0


# Called when the node enters the scene tree for the first time.
func _ready():
	cursor = get_tree().get_first_node_in_group("Cursor")
	inputHandler = get_tree().get_first_node_in_group("InputHandler")

	assert(cursor, "Enemy %s needs cursor" %name)
	assert(inputHandler, "Enemy %s needs inputHandler" %name)


	assert(idleState, "Enemy %s has no reference to required Idle State BehaviorState node" %name)
	assert(chaseState, "Enemy %s has no reference to required Chase State BehaviorState node" %name)

	## Set default state
	set_active_state(idleState)
	#host.give_impulse(Vector2(50,0))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	super._process(_delta) ## Required call to parent _process() function (updates important timers)
	
	sinceLastImpact += _delta

	if physicsMode:
		if physicsVelocity.length() < minPhysicsVelocity and !grabbed:
			physicsMode = false ## If we have no force enemy should leave physics mode
			host.currentlyPossesable = true
		else: update_physics(_delta)


	if !host.is_alive(): impulseDamping = 8.0

#func do_enemy_physics(_delta:float):

func grab(_grabber:HostController):
	grabbed = true
	physicsMode = true
	grabberHost = _grabber
	host.currentlyPossesable = false

func end_grab():
	var grabingPlayer:ThrowingPlayer = grabberHost.playerController as ThrowingPlayer
	grabingPlayer.release_enemy()


func update_physics(_delta:float):
	if host.is_possessable(): host.currentlyPossesable = false

	host.velocity = physicsVelocity
	physicsVelocity = physicsVelocity.lerp(Vector2.ZERO, impulseDamping * _delta)
	
	var beforeVel:= host.velocity
	host.move_and_slide()
	_check_collisions(_delta, beforeVel)

func _check_collisions(_delta:float, _lastFrameVel:Vector2):
	for i in host.get_slide_collision_count():
		var col:KinematicCollision2D = host.get_slide_collision(i)
		var normal:Vector2 = col.get_normal()
		
		var impact_speed:float = abs(_lastFrameVel.dot(normal))
		#print("IMPACT: ", impact_speed)
		
		
		if sinceLastImpact > 0.15 and impact_speed > 100.0:
			impact_response(impact_speed, col, _lastFrameVel)

func impact_response(_force:float, _col:KinematicCollision2D, _lastVel:Vector2):
	if grabbed: end_grab()
	
	var reflectionDir:Vector2 = _lastVel.bounce(_col.get_normal())

	physicsVelocity = reflectionDir.normalized()*_force * reboundForce
	sinceLastImpact = 0.0

	var dmg:float = _force * 0.002
	#print("Take dmg: ", dmg)
	host.hurt(dmg)
	
	## STUN
	if _force >= collisionStunThreshold:
		if host.is_alive(): stun(2.0)
		
		var other := _col.get_collider()
		if other is HostController:
			var otherHost:HostController = other as HostController
			if !otherHost.is_possessed():
				otherHost.enemyController.stun(2.0)
				otherHost.hurt(dmg/2.0)


func give_impulse(_force:Vector2):
	physicsVelocity += _force


func do_enemy_behavior(_delta:float):
	if physicsMode: return

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
