## [PlayerController] – Abstract class that acts as a controller for all player behavior of this host type
##
## [b]Responsibilities:[/b] [br]
##   - Retrieve input from InputHandler class [br]
##   - Interprets player input and instructs relevent nodes to perform tasks [br]
class_name PlayerController extends Node

## ===== SCRIPT VARIABLES =====
var host:HostController

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
