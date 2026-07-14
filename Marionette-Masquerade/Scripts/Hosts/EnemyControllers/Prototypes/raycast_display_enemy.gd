## [SimpleEnemyController] – A simple override of the EnemyController, uses repurposed Host code from GGJ version
##
## [b]Responsibilities:[/b] [br]
##   - Override do_enemy_behavior() function [br]
##   - Use state machine to control enemy thinking [br]
class_name RaycastEnemy extends SimpleEnemy

@export var debugSprite:Sprite2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _enemy_process(_delta):
	super._enemy_process(_delta)
	var canSeePlayer:bool = host.has_LOS_to_host(host.hostManager.playerHost, 10000.0)
	if  canSeePlayer != debugSprite.visible:
		debugSprite.visible = canSeePlayer

func on_possession()->void:
	debugSprite.visible = false
	super.on_possession()


