class_name SimpleChaseBehavior extends BehaviorState


## ===== SCRIPT VARIABLES ===== ##
@export var stopChaseDistance := 500.0
@export var attackDistance := 300.0
@export var attackDelay := 0.3

var attackTarget:HostController

var attackDelayTimer := 0.0


## ===== VIRTUAL FUNCTION OVERRIDES ===== ##

func do_behavior(_delta):
	if !enemy.is_confused(): attackTarget = enemy.targetHost
	
	if !attackTarget: return ## If attack target is null: don't do anything

	if _dist_to_target() >= attackDistance and enemy.navTargetHost == null:
		_reset_attack_delay()
		enemy.path_to_host(attackTarget)
	
	elif host.has_LOS_to_host(attackTarget, attackDistance):
		if enemy.is_moving(): enemy.halt_movement()
			#_reset_attack_delay() # reset attack delay if we are just reaching our target
		
		enemy._lerp_look_at_pos(_delta, attackTarget.global_position) # look towards our target
		print("I WANNA SHOOT")

		if _should_shoot(_delta): enemy.weapon.request_shoot(host.get_forward()) # shoot our target if we are allowed
	else: 
		print("LOS: ", host.has_LOS_to_host(attackTarget, attackDistance))
		print("Close Enough: ", _dist_to_target() < attackDistance)
		print("LOS: ", host.has_LOS_to_host(attackTarget, attackDistance))
		print("Attack Delay")

func on_state_enter():
	attackDelayTimer = attackDelay ## reset attack pause timer
	
	host.velocity = Vector2.ZERO
	
	enemy.halt_movement()

func on_state_exit(): 
	_reset_attack_delay()

func get_status()->BehaviorStatus:
	
	if _dist_to_target() > stopChaseDistance or !attackTarget.is_alive(): ## Return Success on player leaving range, not existing, or dying
		return BehaviorStatus.SUCCESS
	else: 
		return BehaviorStatus.INCOMPLETE


## ===== HELPER FUNCTIONS ===== ##

## Returns distance to attackTarget, -1.0 if attackTarget is null
func _dist_to_target()->float:
	if attackTarget: return host.global_position.distance_to(attackTarget.global_position)
	else: return -1.0

## Checks if host should shoot (maybe after a delay or with LOS)
func _should_shoot(_delta:float)->bool:
	var targetDir:Vector2 = host.global_position.direction_to(attackTarget.global_position)
	attackDelayTimer -= _delta
	
	if !host.looking_in_dir(targetDir, 10.0): return false ## should not shoot if not looking at target
	if attackDelayTimer > 0.0 : return false ## should not shoot until attackDelay is over

	return true ## If all above requirements are met, enemy can shoot

func _reset_attack_delay(): attackDelayTimer = attackDelay
