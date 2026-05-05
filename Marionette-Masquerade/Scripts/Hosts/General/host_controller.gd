## [HostController] – Acts as a manager and property container for each host type
##
## [b]Responsibilities:[\b] [br]
##   - Contains references to all MANDATORY modules for hosts to function (Enemy & Player Controller classes, switch indicator sprite, animation controller, etc) [br]
##   - Calls the update function of either Player or Enemy controller depending on whether the host is currently posessed [br]
##	 - Contains functions callable by Enemy and Player controller to update things like animations & other status updates [br]
##	 - Inherits from CharacterBody2D in order to handle movement [br]
class_name HostController extends CharacterBody2D

## ===== MODULE REFERENCES =====
@export_category("Required References")
@export_group("Main Modules")
@export var enemyController:EnemyController
@export var playerController:PlayerController
@export var inputHandler:InputHandler
@export var animationPlayer:AnimationPlayer
@export var weaponHandler:WeaponHandler

@export_group("Other Nodes")
@export var collider:CollisionShape3D

## ===== EXPORT VARIABLES =====
@export_category("Host Propperties")
@export var hostTypeName:String

@export_group("Status")
@export var currentlyPossesed:bool = false
@export var currentlyPossesable:bool = true

@export_group("Movement")
@export var moveSpeed:float = 10.0

@export_group("Other")
@export var MAX_HEALTH:float = 1.0
@export var MAX_TRANSFER_DISTANCE:float = 250.0 ## Maximum distance that host can transfer to


## ===== SCRIPT VARIABLES =====
@onready var alive:bool = true
var currnentHealth:float


## ===== BOOLEAN RETURN FUNCTIONS =====
func is_posessed()->bool: return currentlyPossesed
func is_posessable()->bool: return currentlyPossesable


## MUST BE CALLED FROM INHERITING CLASSES VIA 'super._ready()'
## Performs mandatory setup for the host class
func _ready():
	## Retrieve input handler from level
	inputHandler = get_tree().get_first_node_in_group("InputHandler")
	
	_verify_core_references() #verify that all required modules/nodes are present and linked

	##Pass reference to self to enemy and player controllers
	playerController.hostController = self
	enemyController.hostController = self


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	## Call the update function of the relevent
	if is_posessed(): playerController.do_player_behavior(delta)
	else: enemyController.do_enemy_behavior(delta)

## Verifies that all propper modules have been linked to HostController
func _verify_core_references()->void:
	assert(enemyController != null,"Host %s is missing reference to required EnemyController" % hostTypeName)
	assert(playerController != null,"Host %s is missing reference to required PlayerController" % hostTypeName)
	assert(weaponHandler != null,"Host %s is missing reference to required WeaponHandler" % hostTypeName)
	assert(inputHandler != null,"Host %s could not retreive reference to InputHandler" % hostTypeName)
	assert(animationPlayer != null,"Host %s is missing reference to required AnimationPlayer" % hostTypeName)
	assert(collider != null, "Host %s is missing reference to its collider" % hostTypeName)


## Tells the animation player to either start or continue the animation of the given name [br]
## [b]Expects:[/b] The given animation name to exist within the animation player [br]
func updateAnimation(_animation_name:String):
	var hasAnimation:bool = animationPlayer.has_animation(_animation_name)
	assert(hasAnimation, "Host %s has no animation called: %s" % [hostTypeName, _animation_name]) #check animation is valid

	if hasAnimation: animationPlayer.play(_animation_name)

## Called by HostManager when player switches to a different host [br]
## Handles: specific switching effects and variable changes [br]
func switch_host(_newHost:HostController)->void:
	currentlyPossesed = false
	updateAnimation("uposess")

#func die(): pass