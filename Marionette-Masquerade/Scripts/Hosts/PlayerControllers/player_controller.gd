## [PlayerController] – Abstract class that acts as a controller for all player behavior of this host type
##
## [b]Responsibilities:[/b] [br]
##   - Retrieve input from InputHandler class [br]
##   - Interprets player input and instructs relevent nodes to perform tasks [br]
##   - Handles effects for when player possesses this host [br]
class_name PlayerController extends Node

## ===== SCRIPT VARIABLES =====
var host:HostController
var weapon:Weapon
var inputHandler:InputHandler
var cursor:Cursor

# Called when the node enters the scene tree for the first time.
func _ready(): pass


## ===== VIRTUAL FUNCTIONS TO OVERRIDE =====

## [b]VIRTUAL[/b][br]
## Called: By HostController every frame that host is possessed by player [br]
## Handles: Interpreting player input and instructing relevent modules to execute behavior [br]
func do_player_behavior(_delta:float): pass

## [b]VIRTUAL[/b][br]
## Called: By HostController every PHYSICS frame that host is possessed by player [br]
## Handles: Interpreting player input and instructing relevent modules to execute behavior [br]
func do_player_physics(_delta:float): pass

## [b]VIRTUAL[/b][br]
## Called: By HostController when player possesses this host [br]
## Handles: Effects and behavior when this host becomes possessed [br]
func on_possession()->void: pass


## ===== HELPER FUNCTIONS =====
