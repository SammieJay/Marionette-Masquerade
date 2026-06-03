## [HostController] – Acts as a manager and property container for each host type
##
## [b]Responsibilities:[/b] [br]
##   - Contains references to all MANDATORY modules for hosts to function (Enemy & Player Controller classes, switch indicator sprite, animation controller, etc) [br]
##   - Calls the update function of either Player or Enemy controller depending on whether the host is currently possessed [br]
##	 - Contains functions callable by Enemy and Player controller to update things like animations & other status updates [br]
##	 - Inherits from CharacterBody2D in order to handle movement [br]
class_name HostController extends CharacterBody2D


## ===== MODULE REFERENCES =====

@export_category("Required References")
@export_group("Main Modules")
@export var enemyController:EnemyController
@export var playerController:PlayerController
@export var effectHandler:HostEffectHandler
@export var weapon:Weapon


@export_group("Other Nodes")
@export var collider:CollisionShape2D
@export var visionRay:RayCast2D
@export var maskSprite:CanvasItem


## ===== EXPORT VARIABLES =====

@export_category("Host Propperties")
@export var hostTypeName:String

@export_group("Status")
@export var currentlyPossesable:bool = true
@export var clearOnDeath:bool = false

@export_group("Movement")
@export var moveSpeed:float = 20.0
@export var rotationSpeed:float = 7.0

@export_group("Health")
@export var MAX_HEALTH:float = 1.0

@export_group("Possession")
@export var possessionReach:float = 0.0 ## How much more than usual reach this host gets to posess other hosts


## ===== SCRIPT VARIABLES =====
# ----- References -----
@onready var inputHandler:InputHandler
@onready var hostManager:HostManager


# ----- Possession -----
@onready var currentlyPossessed:bool = false

# ----- Health -----
@onready var alive:bool = true
@onready var currentHealth:float

# ----- Movement -----
const MOVE_SPEED_CONST:float = 1200.0


## ===== BOOLEAN RETURN FUNCTIONS =====

func is_possessed()->bool: return currentlyPossessed
func is_possessable()->bool: return currentlyPossesable
func is_alive()->bool: return alive


## ===== GETTER AND SETTER FUNCTIONS =====

func get_forward()->Vector2: return Vector2(1,0).rotated(global_rotation).normalized() ## Returns the vector pointed forward from the host
func get_right()->Vector2: return Vector2(0,1).rotated(global_rotation).normalized() ## Returns the vector along the right direction of the host


## MUST BE CALLED FROM INHERITING CLASSES VIA 'super._ready()'
## Performs mandatory setup for the host class
func _ready():
	## Retrieve input handler from singleton group
	inputHandler = get_tree().get_first_node_in_group("InputHandler")
	hostManager = get_tree().get_first_node_in_group("HostManager")
	_verify_core_references() #verify that all required modules/nodes are present and linked
	_distribute_references() #pass important refrences to relevent modules
	_set_inital_values() #set important initial variable values

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	
	## Call the update function of the relevent Controller
	if is_possessed() and is_alive(): playerController.do_player_behavior(_delta)
	elif !enemyController.disableAI and is_alive(): enemyController.do_enemy_behavior(_delta)

func _physics_process(_delta):
	## Call the update function of the relevent Controller
	if is_possessed() and is_alive(): playerController.do_player_physics(_delta)
	elif !enemyController.disableAI and is_alive(): enemyController.do_enemy_physics(_delta)


## ===== CORE FUNCTIONS CALLED FROM OTHER CLASSES =====

## Called by HostManager when player switches to a different host [br]
## Handles: value changes and effects that occur when switching [b]FROM[/b] this host  [br]
func un_possess()->void:
	currentlyPossessed = false
	effectHandler.play_switch_effect(true)
	maskSprite.hide()
	enemyController.on_possession_release()
	

## Called by HostManager when player switches to a different host [br]
## Handles: value changes and effects that occur when switching [b]TO[/b] this host  [br]
func possess()->void:
	currentlyPossessed = true
	maskSprite.show()
	playerController.on_possession()
	if weapon.forceReloadOnPosession: weapon.force_reload() # Force reload weapon if handler has flag enableda

## Inflict dammage to this host
func hurt(_dmg:float)->void:
	currentHealth -= _dmg
	
	
	if currentHealth <= 0.0:
		die()

## Kill host and play death effect
func die()->void:
	alive = false
	effectHandler.play_death_effect()
	if clearOnDeath: clear()

## Delete & Clear this host from memory
func clear()->void:
	queue_free()


## ===== HELPER FUNCTIONS =====

## Verifies that all propper modules have been linked to HostController
func _verify_core_references()->void:
	assert(enemyController != null,"Host %s is missing reference to required EnemyController" % hostTypeName)
	assert(playerController != null,"Host %s is missing reference to required PlayerController" % hostTypeName)
	assert(weapon != null,"Host %s is missing reference to required weapon" % hostTypeName)
	assert(inputHandler != null,"Host %s could not retreive reference to InputHandler" % hostTypeName)
	assert(effectHandler != null,"Host %s is missing reference to required EffectHandler" % hostTypeName)
	assert(collider != null, "Host %s is missing reference to its collider" % hostTypeName)
	assert(visionRay != null, "Host %s is missing reference to required RayCast2D" % hostTypeName)

## Pass references to mandatory modules to nodes that require them at runtime
func _distribute_references()->void:
	# --- PlayerController ---
	playerController.host = self
	playerController.weapon = weapon
	playerController.inputHandler = inputHandler

	# --- EnemyController ---
	enemyController.host = self
	enemyController.weapon = weapon

	# --- Weapon ---
	weapon.host = self

## Set initial variable values at runtime
func _set_inital_values()->void:
	currentHealth = MAX_HEALTH


## ===== EXTRA HELPER/STATE CHECKING FUNCTIONS ===== ##

## Returns whether this host has line of sight on the given target host, within the given max distance
func has_LOS_to_host(_target:HostController, _maxDist:float)->bool:
	if !_target: return false

	var distToTarget = _target.global_position.distance_to(global_position)
	if distToTarget >= _maxDist: return false ## Return false if target is too far
	
	#line of sight check
	visionRay.target_position = visionRay.to_local(_target.global_position)
	visionRay.force_raycast_update()
	var hit = visionRay.get_collider()
	
	if !hit: return false ## For redundancy, if no collider is hit, return false (probably wont happen since ray collides with our collider)

	## Return false if a collider is hit, its not our's and it is not the target's collider
	if hit != _target and hit != collider: return false
	
	#print("Host ", hostTypeName, " LOS hit on ", _target.name, " within: ", _maxDist) # Debug Print
	return true

## Returns Whether host can see the given position
func has_LOS_to_position(_pos:Vector2)->bool:
	var toTarget = _pos - global_position
	
	#line of sight check
	visionRay.target_position = toTarget
	visionRay.force_raycast_update()
	
	if visionRay.get_collider() != collider: return false
	else: return true


## Is this host looking towards the given direction vector (with a given margin of error in degrees)
func looking_in_dir(_targetDir:Vector2 , _margin:float)->bool:
	return rad_to_deg(get_forward().angle_to(_targetDir)) <= _margin
