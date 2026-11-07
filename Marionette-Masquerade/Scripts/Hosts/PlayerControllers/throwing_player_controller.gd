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
@export var trackingForce:float = 20.0
@export var maxTrackingStr:float = 11.0
@export var grabRange:float = 200.0
@export_range(0.0,1.2,0.05,"Movement Scalar when grappling") 
var grabMovementPenaltyScalar:float = 1.0

@export_category("Hold Properties")
@export var holdDistance:float = 120.0			# distance from player the enemy is held at
@export var maxHoldStr:float = 200.0        	# cap on correction velocity when snapping to hold position (px/sec)
@export var holdRotationSpeed:float = 10.0     	# how fast held enemy turns to face aimDir

@export_category("Shove Properties")
@export var shoveForce: float = 800.0


## ===== SCRIPT VARIABLES ===== ##

var grabbedHost:HostController = null
var grabbedEnemy:EnemyController = null
var grabbedImpulseBody:ImpulseBody = null

## ===== FUNCTION OVERRIDES =====
func do_player_behavior(_delta:float):
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

	if grabbedHost: update_grab(_delta)

func on_possession()->void:
	pass

func on_possession_release()->void:
	if grabbedEnemy: release_enemy() #end grab if active when swapping




## ===== GRAPPLE AND THROW FUNCTIONS ===== ##

## Start grab on given enemy
func grab_enemy(_host:HostController)->void:
	grabbedHost = _host
	grabbedEnemy = _host.enemyController
	grabbedImpulseBody = grabbedEnemy.impulseBody

	grabbedEnemy.forcePhysicsState = true
	grabbedImpulseBody.impact.connect(_on_enemy_collision) ##When collision signal is emitted, release the enemy
	cursor.set_global_pos(grabbedHost.global_position)
	grapple.attach_to_node(grabbedHost)
	grabbedHost.giveTempHP(2.0)
	grabbedHost.collider.set_deferred("disabled", true) # DISABLE COLLIDER DURRING GRAB FOR TESTING EASE

## End an active grab
func release_enemy():
	grabbedHost.collider.set_deferred("disabled", false) # RE-ENABLE COLLIDER AFTER DISABLING FOR TESTING EASE
	grabbedHost.clearTempHP()
	grabbedEnemy.forcePhysicsState = false
	grabbedImpulseBody.impact.disconnect(_on_enemy_collision)
	grabbedHost = null
	grabbedEnemy = null
	grabbedImpulseBody = null
	grapple.detach()

## Called every frame while a host is grabbed. [br]
## Holds the grabbed host at holdDistance from the player, aimed towards the cursor
func update_grab(_delta:float):
	if inputHandler.is_action_just_released("Grapple"):
		release_enemy()
		return
	
	var aimDir:Vector2 = _get_aim_dir()

	var targetPos:Vector2 = host.global_position + (aimDir * holdDistance) + (host.velocity * 0.2)
	grabbedImpulseBody.move_towards_position(targetPos, _delta, trackingForce)

	grabbedImpulseBody.turn_towards_direction(aimDir, _delta)

	if !grabbedHost.is_alive(): release_enemy()


func shove_enemy(_dir:Vector2):
	grabbedImpulseBody.give_impulse(_dir * shoveForce)
	release_enemy()




## ===== HELPER FUNCTIONS =====

## Singal receiver function, currently just releases grapple when collision occurs
func _on_enemy_collision(_force:float, _col:KinematicCollision2D, _vel:Vector2):
	release_enemy()

## Returns the direction from the player to the cursor as a normalized Vector2
func _get_aim_dir()->Vector2:
	var toCursor:Vector2 = cursor.global_position - host.global_position
	if toCursor.length() < 0.001: return host.get_forward()
	return toCursor.normalized()
