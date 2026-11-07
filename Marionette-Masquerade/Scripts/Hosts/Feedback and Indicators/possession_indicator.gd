## [PossessionIndicator] – A simple class that controls the inidcator above posessable hosts
##
## [b]Responsibilities:[/b] [br]
##   - Move to the host that the player can currently posess [br]
##   - Appear and dissapear as required [br]
class_name PossessionIndicator extends Node2D


## ===== SCRIPT VARIABLES =====

@onready var targetHost:HostController = null
@onready var active:bool = false
@onready var sprite:AnimatedSprite2D = $Sprite


## ===== CORE FUNCTIONS =====

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if targetHost == null: active = false
	if active == false and targetHost != null: targetHost = null
	
	if active:
		global_position = targetHost.global_position
		if !sprite.visible: sprite.visible = true
	else: sprite.visible = false

## Set target for indicator to follow and highlight, if input is null -> does nothing
func set_target(host:HostController):
	if host != null:
		#print("Targeting %s" % host.hostTypeName)
		targetHost = host
		active = true
	else: 
		active = false
		#print("No Target Found")
