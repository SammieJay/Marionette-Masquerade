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


## ===== EXPORT VARIABLES =====

@export_category("Host Propperties")
@export var hostTypeName:String

@export_group("Status")
@export var currentlyPossesable:bool = true
@export var clearOnDeath:bool = true

@export_group("Movement")
@export var moveSpeed:float = 20.0
@export var rotationSpeed:float = 7.0

@export_group("Other Values")
@export var MAX_HEALTH:float = 1.0
@export var MAX_TRANSFER_DISTANCE:float = 100.0 ## Maximum distance that host can transfer to


## ===== SCRIPT VARIABLES =====
# ----- References -----
@onready var inputHandler:InputHandler
@onready var hostManager:HostManager

# ----- possession -----
@onready var currentlyPossessed:bool = false

# ----- Health -----
@onready var alive:bool = true
@onready var currnentHealth:float

# ----- Movement -----
const MOVE_SPEED_CONSTANT:float = 1200.0


## ===== BOOLEAN RETURN FUNCTIONS =====

func is_possessed()->bool: return currentlyPossessed
func is_possessable()->bool: return currentlyPossesable
func is_alive()->bool: return alive


## ===== GETTER AND SETTER FUNCTIONS =====

func get_forward()->Vector2: return Vector2(1,0).rotated(global_rotation).normalized() ## Returns the vector pointef forward from the host
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
	## Call the update function of the relevent
	if is_possessed(): playerController.do_player_behavior(_delta)
	else: enemyController.do_enemy_behavior(_delta)


## ===== CORE FUNCTIONS CALLED FROM OTHER CLASSES =====

## Called by HostManager when player switches to a different host [br]
## Handles: value changes and effects that occur when switching [b]FROM[/b] this host  [br]
func un_possess()->void:
	currentlyPossessed = false
	effectHandler.play_switch_effect(true)
	enemyController.on_possession_release()
	

## Called by HostManager when player switches to a different host [br]
## Handles: value changes and effects that occur when switching [b]TO[/b] this host  [br]
func possess()->void:
	currentlyPossessed = true
	playerController.on_possession()
	if weapon.forceReloadOnPosession: weapon.force_reload() # Force reload weapon if handler has flag enabled

## Inflict dammage to this host
func hurt(_dmg:float)->void:
	currnentHealth -= _dmg
	if currnentHealth <= 0.0:
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
	currnentHealth = MAX_HEALTH
