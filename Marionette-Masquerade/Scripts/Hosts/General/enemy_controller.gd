## [EnemyController] – Abstract class that acts as a controller for all enemy behavior of this host type
##
## [b]Responsibilities:[/b] [br]
##   - Contains functions for general AI behavior like pathing [br]
##   - Is inherited to make an enemy controller specific to each host type [br]
##   - Retrieves references to other nodes via the HostController [br]
class_name EnemyController extends Node


## ===== EXPORT VARIABLES =====
@export_category("Enemy Propperties")
@export var hostTypeName:String

@export_group("Status")
@export var currentlyPossesed:bool = false
@export var currentlyPossesable:bool = true

@export_group("Movement")
@export var moveSpeed:float = 10.0

@export_group("Other")
@export var MAX_HEALTH:float = 1.0
## Maximum distance that host can transfer to
@export var MAX_TRANSFER_DISTANCE:float = 250.0


## ===== SCRIPT VARIABLES =====
var hostController:HostController

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

## VIRTUAL
## Called every frame by HostController
## Handles all enemy thinking and behavior by calling functions in other nodes
func do_enemy_behavior(delta:float): pass