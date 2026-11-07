## [ImpulseBody] – Custom physics handler for hosts and physically controllable props like explosive barrles
##
## [b]Responsibilities:[/b] [br]
##   - Do physics calculations for involuntary movement of physics props and enemies [br]
##   - emit signal when impacts occur with relevent information [br]
##   - move parent CharacterBody2D class in accordance to implemented physics [br]

@tool

class_name ImpulseBody extends Node

## Signal is emited upon colision, other nodes can listen to this signal to know when a colision happens and recieve information about the collision
signal impact(_force:float, _col:KinematicCollision2D, _pre_vel:Vector2)

@export_category("Linear Physics")
@export var impulseDamping:float = 2.0 ## How aggressively this object slows down when under the effect of impulse physics (basically represents mass)
@export var minPhysicsVelocity:float = 1.0 ## The slowest the object can be moving before the component self de-activates (Irrelevant when forceActive is true)
@export var minColisionVelocity:float = 100.0 ## the minimum velocity required for a colision to be registered

@export_group("Rebounds")
@export var doRebounds:bool = false ## Decides whether this body will bounce off of walls or other bodies
@export_range(0.0, 1.0, 0.05) var reboundForce:float = 0.25 ##How much of the velocity is reflected in the rebound as a scalar [br] (1.0 no velocity is lost, 0.5 half of velocity is lost)

@export_category("Angular Physics")
@export var angularDamping:float = 3.0 ## How aggressively rotation slows down after a spin impulse
@export var minAngularVelocity:float = 0.05 ## Below this (rad/sec), angular velocity snaps to zero
@export var maxAngularVelocity:float = 20.0 ## Hard cap to prevent runaway spin from large off-center impacts

var body:CharacterBody2D ## the body that this component is applying it's physics math to
var physicsVelocity:Vector2 = Vector2.ZERO ## Velocity in units/frame
var angularVelocity:float = 0.0 ## In radians/sec, positive = clockwise
var sinceLastImpact:float = 0.0 ## Timer since last collision to ensure multiple collisions don't occur near simultaneously

var active:bool = false ## when true - parent object's movement is controlled by this node, when false - this node has no effect on parent object
var forceActive:bool = false ## when true - this component will not self de-activate because of too little movement. This is true when entities are grabbed by the player

func is_settled()->bool: return physicsVelocity.length() < minPhysicsVelocity and abs(angularVelocity) < minAngularVelocity


## ===== BASE FUNCTIONS ===== ##
func _ready():
	body = get_parent() as CharacterBody2D

func _physics_process(_delta:float):
	sinceLastImpact += _delta # add to counter

	if active and !forceActive and is_settled(): disable_physics() # Disable this component if active and velocity is below given threshold
	elif forceActive or (!active and !is_settled()): active = true # Set as enabled if physics requirements are met

	if active: _update_physics(_delta)


## ===== PHYSICS FUNCITONS ===== ##

##  --- PUBLIC --- ##

## Apply linear impulse
func give_impulse(_force:Vector2): physicsVelocity += _force

## Apply angular impulse
func give_angular_impulse(_torque:float): angularVelocity = clampf(angularVelocity + _torque, -maxAngularVelocity, maxAngularVelocity)

## Stop any movement and set component as inactive
func disable_physics():
	active = false
	forceActive = false
	physicsVelocity = Vector2.ZERO
	angularVelocity = 0.0

## Call this function every physics frame to rotate the body towards the given direction vector
func turn_towards_direction(_goalDir:Vector2, _delta:float, _stiffness:float = 25.0):
	if _delta <= 0.0 or _goalDir.length() < 0.001: return

	var goalAngle:float = _goalDir.angle()
	var angleDiff:float = wrapf(goalAngle - body.rotation, -PI, PI) # shortest signed angle difference to goal angle

	## Critically damped spring towards zero angleDiff, same shape as give_impulse spring math
	var springStr:float = _stiffness * _stiffness
	var neededDamping:float = 2.0 * _stiffness

	## Account for already applied rotational damping
	var addedDamping:float = max(0.0, neededDamping - angularDamping)
	
	var angularAccel:float = springStr * angleDiff - addedDamping * angularVelocity

	give_angular_impulse(angularAccel * _delta)


## Drives body towards _targetPos every frame that this function is called
func move_towards_position(_target_pos:Vector2, _delta:float, _stiffness:float = 10.0):
	if _delta <= 0.0: return
	
	var toTarget:Vector2 = body.global_position - _target_pos
	
	var currentVel:Vector2 = physicsVelocity

	var springStr:float = _stiffness * _stiffness
	var neededDamping:float = 2.0 * _stiffness

	##Damping needed on top of what is applied by default in EnemyController
	var addedDamping:float = max(0.0, neededDamping - impulseDamping)

	var accel:Vector2 = -springStr * toTarget - addedDamping * currentVel
	
	give_impulse(accel * _delta)


## --- PRIVATE --- ##

## Updated every frame when active variable is true, updates the physics and movement of parent CharacterBody2D
func _update_physics(_delta:float):
	# --- Linear ---
	body.velocity = physicsVelocity
	physicsVelocity = physicsVelocity.lerp(Vector2.ZERO, impulseDamping * _delta) # Damp the physics velocity over time
	
	var beforeVel:= body.velocity
	body.move_and_slide()
	_check_collisions(_delta, beforeVel)

	# --- Angular ---
	_update_rotation(_delta)

## Called from update_physics() when active
func _check_collisions(_delta:float, _lastFrameVel:Vector2):
	for i in body.get_slide_collision_count():
		var col:KinematicCollision2D = body.get_slide_collision(i)
		var normal:Vector2 = col.get_normal()
		
		var impact_speed:float = abs(_lastFrameVel.dot(normal))
		#print("IMPACT: ", impact_speed)
		
		if sinceLastImpact > 0.15 and impact_speed > minColisionVelocity:
			_impact_response(impact_speed, col, _lastFrameVel)

## Respond physically to impacts that occur
func _impact_response(_force:float, _col:KinematicCollision2D, _lastVel:Vector2):
	if doRebounds:
		var reflectionDir:Vector2 = _lastVel.bounce(_col.get_normal())
		physicsVelocity = reflectionDir.normalized() * _force * reboundForce
	else: disable_physics()
	
	sinceLastImpact = 0.0
	impact.emit(_force, _col, _lastVel)

## Ticks rotation forward and damps angular velocity towards zero
func _update_rotation(_delta:float):
	if angularVelocity == 0.0: return

	body.rotation += angularVelocity * _delta
	angularVelocity = lerp(angularVelocity, 0.0, angularDamping * _delta)

	if abs(angularVelocity) < minAngularVelocity:
		angularVelocity = 0.0

## ===== DEBUG FUNCTIONS ===== ##

## Display warning when this node is not a child of CharacterBody2D (It must be to function properly)
func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	
	if not (get_parent() is CharacterBody2D):
		warnings.append("ImpulseBody must be a child of a CharacterBody2D node to function correctly.")
	
	return warnings
