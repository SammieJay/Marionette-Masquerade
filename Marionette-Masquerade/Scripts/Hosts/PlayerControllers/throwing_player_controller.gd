## ThrowingPlayer – PlayerController that grabbs enemies and throws them with a tentacle
##
## [b]Responsibilities:[/b] [br]
##   - Throw enemies [br]
class_name ThrowingPlayer extends PlayerController

## Export Vars
@export_category("Tentacle Properties")
@export var grapple : GrappleTentacle
@export var grappleScene: PackedScene         	# GrappleTentacle.tscn
@export var strandScatter: float = 0.08        	# aim spread in radians per extra strand
@export var pullStopDistance: float = 16.0		# stop pulling once this close

@export_category("Grabber Properties")
@export var trackingForce:float = 0.05
@export var maxTrackingStr:float = 11.0
@export var grabRange:float = 200.0
@export_range(0.0,1.2,0.05,"Movement Scalar when grappling") 
var grabMovementPenaltyScalar:float = 1.0

@export_category("Hold Properties")
@export var holdDistance:float = 120.0			# distance from player the enemy is held at
@export var maxHoldStr:float = 2000.0        	# cap on correction velocity when snapping to hold position (px/sec)
@export var holdRotationSpeed:float = 10.0     	# how fast held enemy turns to face aimDir

@export_category("Shove Properties")
@export var shoveForce: float = 800.0


## ===== SCRIPT VARIABLES ===== ##
var extraStrands: Array[GrappleTentacle] = []   # spawned copies

var grabbedHost:HostController = null
var grabbedEnemy:EnemyController = null

## ===== FUNCTION OVERRIDES =====
func do_player_behavior(_delta:float):
	
	if grabbedHost: update_grab(_delta)
	
	## === WEAPON CODE ===
	if inputHandler.is_action_just_pressed("Shoot"):
		if grabbedHost: shove_enemy(_get_aim_dir())
		else: weapon.request_shoot(host.get_forward())

	

func _ready():
	super._ready() ## Parent ready call

	grapple.maxDistance = grabRange
	grapple.breakDistance = grabRange


func do_player_physics(_delta:float):
	## === MOVEMENT CODE ===
	var moveVector = inputHandler.get_move_input() ## retrieve normalized movement input vector from InputHandler
	# Apply movement
	var moddedMoveSpeed:float = host.moveSpeed * GlobalDefs.MOVE_SPEED_CONST * _delta
	if grabbedEnemy: moddedMoveSpeed *= grabMovementPenaltyScalar
	host.velocity = moveVector * moddedMoveSpeed

	# === GRAPPLE PULL ===
	host.move_and_slide()
	

	# --- Rotation (face mouse) ---
	var aimPos = cursor.global_position
	var lookDir = (aimPos - host.global_position).normalized()
	var targetDir = lookDir.angle()
	
	#inerpolate towards targetDirection
	host.global_rotation = lerp_angle(host.global_rotation, targetDir, host.rotationSpeed*_delta)
	

func on_posession()->void:
	pass

## ===== HELPER FUNCTIONS =====

func grab_enemy(_host:HostController)->void:
	grabbedHost = _host
	grabbedEnemy = _host.enemyController
	grabbedEnemy.forcePhysicsState = true
	grabbedEnemy.collision.connect(_on_enemy_collision) ##When collision signal is emitted, release the enemy
	#cursor.set_global_pos(grabbedHost.global_position)
	grapple.attach_to_node(_host)
	

func release_enemy():
	grabbedEnemy.forcePhysicsState = false
	grabbedEnemy.collision.disconnect(_on_enemy_collision)
	grabbedHost = null
	grabbedEnemy = null
	grapple.start_retract()


func _fire_grapple() -> void:
	# prune any freed/finished strands from the previous shot
	extraStrands = extraStrands.filter(func(g): return is_instance_valid(g))
	for g in extraStrands:
		g.start_retract()        # retract any lingering ones before new fire
	extraStrands.clear()
	var n := randi_range(1, 10)
	for i in n:
		var g: GrappleTentacle = grapple
		var aim: Vector2 = host.get_forward()
		if i > 0:
			# extra strands: fresh instances that clean themselves up
			g = grappleScene.instantiate()
			get_parent().add_child(g)
			g.muzzle = grapple.muzzle
			g.freeOnDetach = true
			extraStrands.append(g)
			aim = aim.rotated(randf_range(-strandScatter, strandScatter))
		g.fire(host.global_position, aim, 400.0)

func _detach_all() -> void:
	grapple.start_retract()
	for g in extraStrands:
		if is_instance_valid(g):
			g.start_retract()

## Singal receiver function, currently just releases grapple when collision occurs
func _on_enemy_collision(_force:float, _col:KinematicCollision2D, _dir:Vector2):
	release_enemy()


## ===== GRAPPLE AND THROW FUNCTIONS ===== ##

## Called every frame while a host is grabbed. [br]
## Holds the grabbed host at holdDistance from the player, aimed towards the cursor, [br]
## and lets the player shove it away on input.
func update_grab(_delta:float):
	""" ## OLD CODE FOR GRAB
	var distToEnemy:float = host.global_position.distance_to(grabbedHost.global_position)

	if distToEnemy > grabRange or inputHandler.is_action_just_released("Grapple"):
		release_enemy()
		return

	var toCursor:Vector2 = (cursor.global_position - grabbedHost.global_position)

	var impulseAdd:Vector2 = toCursor*trackingForce
	var cappedAdd:Vector2 = impulseAdd

	if impulseAdd.length()>maxTrackingStr:
		cappedAdd = impulseAdd.normalized()*maxTrackingStr
			
	#print("Impulse Add STR ", cappedAdd.length())
	grabbedEnemy.give_impulse(cappedAdd)
	"""


	if inputHandler.is_action_just_released("Grapple"):
		release_enemy()
		return
	
	var aimDir:Vector2 = _get_aim_dir()

	var targetPos:Vector2 = host.global_position + aimDir * holdDistance
	_move_grabbed_host_towards(targetPos, _delta)

	grabbedEnemy._lerp_look_at_pos(_delta, grabbedHost.global_position + aimDir)


func shove_enemy(_dir:Vector2):
	grabbedEnemy.give_impulse(_dir * shoveForce)
	release_enemy()


## Drives the grabbed host towards _targetPos this frame via velocity + move_and_slide, [br]
## so it still respects walls/collisions rather than teleporting through them.
func _move_grabbed_host_towards(_target_pos:Vector2, _delta:float):
	if _delta <= 0.0: return
	
	var toTarget:Vector2 = _target_pos - grabbedHost.global_position
	var desiredVelocity:Vector2 = toTarget * toTarget.length() * trackingForce

	print(toTarget.length())

	# Cap adjusting velocity
	if desiredVelocity.length() > maxHoldStr:
		desiredVelocity = desiredVelocity.normalized() * maxHoldStr
	
	
	grabbedEnemy.give_impulse(desiredVelocity)

func _get_aim_dir()->Vector2:
	var toCursor:Vector2 = cursor.global_position - host.global_position
	if toCursor.length() < 0.001: return host.get_forward()
	return toCursor.normalized()