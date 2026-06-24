## [ThrowingHostManager] – Inherits functionality of Host Manager
##
## [b]Responsibilities:[/b] [br]
##   - Select an elegible host for the player to switch to [br]
##   - Does grabbing trigger based on switch distance and stuff [br]
class_name ThrowingHostManager extends HostManager

var eligibleGrab:HostController = null
var playerCanGrab:bool = false

func _process(_delta: float) -> void:
	super._process(_delta)

	if eligibleHost != eligibleGrab:
		if eligibleHost:
			eligibleGrab = eligibleHost
		else: eligibleGrab = null

	if inputHandler.is_action_just_pressed("Grapple") and eligibleGrab:
		if playerHost.playerController is ThrowingPlayer:
			(playerHost.playerController as ThrowingPlayer).grab_enemy(eligibleGrab)

	



