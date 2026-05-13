## [SimpleEnemyController] – A simple override of the EnemyController, duplicate this class when creating new subclasses
##
## [b]Responsibilities:[/b] [br]
##   - Override do_enemy_behavior() function [br]
##   - Use state machine to control enemy thinking [br]
class_name SimpleEnemy extends EnemyController


# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready() ## Required call to parent _ready() function (does important setup)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	super._process(_delta) ## Required call to parent _process() function (updates important timers)

func do_enemy_behavior(_delta:float):
	## PATHFINDING CODE TEST
	if host.inputHandler.is_action_just_pressed("Shoot"):
		var pos = host.inputHandler.get_mouse_global_position()
		#path_to_position(pos)
		#path_to_host(host.hostManager.playerHost, 75.0)
		#print("Telling host to path to: ", pos)

func on_possession_release()->void: pass

