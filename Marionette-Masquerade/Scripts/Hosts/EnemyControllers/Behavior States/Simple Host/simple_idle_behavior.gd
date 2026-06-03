class_name SimpleIdleBehavior extends BehaviorState

var idleTimer:= 0.0
var idleLookTargetAngle := 0.0
var leaveIdleDistance := 450.0
@export var idleLookInterval := 2.5

func do_behavior(_delta):
	idleTimer -= _delta
	if enemy.idleTimer < 0.0: # Reset look interval
		idleTimer = idleLookInterval + randf_range(-2.0, 2.0)
		var angle = deg_to_rad(randf_range(-180, 180))
		idleLookTargetAngle = enemy.host.rotation + angle
	
	#print("looking towards: ", idleLookTargetAngle)
	enemy._lerp_look_to_angle(_delta, idleLookTargetAngle)

func on_state_enter(): 
	host.velocity = Vector2.ZERO
	enemy.halt_movement()

func on_state_exit(): pass

## Returns SUCCESS if enemy should aggro player, INCOMPLETE otherwise
func get_status()->BehaviorStatus:
	if host.has_LOS_to_host(enemy.targetHost, leaveIdleDistance):
		return BehaviorStatus.SUCCESS
	else: 
		return BehaviorStatus.INCOMPLETE
