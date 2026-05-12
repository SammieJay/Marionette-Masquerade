## [EnemyController] – Abstract class that acts as a controller for all enemy behavior of this host type
##
## [b]Responsibilities:[/b] [br]
##   - Contains functions for general AI behavior like pathing [br]
##   - Is inherited to make an enemy controller specific to each host type [br]
##   - Retrieves references to other nodes via the HostController [br]
##   - Handles effects for when player stops possessing this host [br]
class_name EnemyController extends Node

## ===== EXPORT VARIABLES =====
@export_category("References")
@export_group("REQUIRED")
@export var navAgent:NavigationAgent2D


@export_category("Enemy Propperties")
@export_group("Movement")
@export var moveSpeed:float = 10.0

@export_group("Other")
@export var confusionDelayTime:float = 1.0 ## How long this host takes to target the player after they switch hosts
@export var postPossessionStunTime:float = 3.0 ## How long this host is stunned after player switches to anoter host


## ===== SCRIPT VARIABLES =====
# ----- References -----
var host:HostController
var weapon:Weapon

# ----- Confusion -----
var confusionTimer:float = 0.0

# ----- Stunned -----
var stunnedTimer:float = 0.0

## ===== BOOLEAN RETURNS =====
func is_confused()->bool: return confusionTimer > 0.0
func is_stunned()->bool: return stunnedTimer > 0.0

## MUST BE CALLED FROM INHERITING CLASSES VIA 'super._ready()'
## Performs mandatory setup for all inheriting EnemyController classes
func _ready(): pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta): 
	## Update Timers
	if confusionTimer >= 0.0: confusionTimer -= _delta
	if stunnedTimer >= 0.0: stunnedTimer -= _delta


## ===== VIRTUAL FUNCTIONS TO BE OVERRIDEN =====

## [b]VIRTUAL[/b][br]
## Called: By HostController every frame that host is not possessed [br]
## Handles: All enemy thinking and decision making [br]
func do_enemy_behavior(_delta:float): pass

## [b]VIRTUAL[/b][br]
## Called: By HostController when player leaves this host [br]
## Handles: Effects and behavior when possession is released [br]
func on_possession_release()->void: pass


## ===== HELPER FUNCTIONS =====

func _verify_refrences()->void:
	assert(navAgent != null, "EnemyController for %s is missing reference to required NavigationAgent2D" % host.hostTypeName)