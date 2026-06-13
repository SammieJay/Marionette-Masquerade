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
@export var trackingForce:float = 0.25
@export var maxTrackingStr:float = 11.0
@export var reboundForce:float = 0.25
@export var takeDmgOnCollide:bool = true

# ----- Physics -----
@onready var impulseVelocity:Vector2 = Vector2.ZERO

## ===== SCRIPT VARIABLES =====
# Idle
var idleTimer := 0.0
var idleLookTarget:float = 0.0

var grabbed:bool = false
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

	if impulseVelocity != Vector2.ZERO: 
		_update_impulse(_delta)


	## MOVE TOWARDS CURSOR
	
	var distToCursor:float = host.global_position.distance_to(cursor.global_position)

	if inputHandler.is_action_pressed("TestInputKey") and distToCursor <= 30.0 and host.is_alive():
		grabbed = true
	
	if inputHandler.is_action_just_released("TestInputKey"): grabbed = false

	if grabbed:
		var toCursor:Vector2 = (cursor.global_position - host.global_position)

		var impulseAdd:Vector2 = toCursor*trackingForce
		var cappedAdd:Vector2 = impulseAdd

		if impulseAdd.length()>maxTrackingStr:
			cappedAdd = impulseAdd.normalized()*maxTrackingStr
			
		print("Impulse Add STR ", cappedAdd.length())
		give_impulse(cappedAdd)
	
	if !host.is_alive(): impulseDamping = 8.0
	
	cursor.visible = !grabbed

#func do_enemy_physics(_delta:float):
	
func _update_impulse(_delta:float):
	host.velocity = impulseVelocity
	impulseVelocity = impulseVelocity.lerp(Vector2.ZERO, impulseDamping * _delta)
	if impulseVelocity.length()<0.5: impulseVelocity = Vector2.ZERO
	var beforeVel:= host.velocity
	host.move_and_slide()
	_check_collisions(_delta, beforeVel)

func _check_collisions(_delta:float, _lastFrameVel:Vector2):
	for i in host.get_slide_collision_count():
		var col:KinematicCollision2D = host.get_slide_collision(i)
		var normal:Vector2 = col.get_normal()
		
		var impact_speed:float = abs(_lastFrameVel.dot(normal))
		#print("IMPACT: ", impact_speed)
		
		
		if sinceLastImpact > 0.15 and impact_speed > 2.0:
			impact_response(impact_speed, col, _lastFrameVel)

func impact_response(_force:float, _col:KinematicCollision2D, _lastVel:Vector2):
	grabbed = false
	
	var reflectionDir:Vector2 = _lastVel.bounce(_col.get_normal())

	impulseVelocity = reflectionDir.normalized()*_force * reboundForce
	sinceLastImpact = 0.0

	var dmg:float = _force * 0.001
	print("Take dmg: ", dmg)
	host.hurt(dmg)
	

func give_impulse(_force:Vector2):
	impulseVelocity += _force


func do_enemy_behavior(_delta:float):
	return
	
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
