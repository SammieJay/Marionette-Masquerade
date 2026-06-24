## TODO: figure out why sometimes feels unresponsive

## Simple_PlayerController – A simple PlayerControllerSubclass for basic functionality
##
## [b]Responsibilities:[/b] [br]

##   - Act as an example subclass of PlayerController [br]
class_name GrapplingPlayer extends PlayerController

## Export Vars
@export var grapple : GrappleTentacle
@export var grappleScene: PackedScene          # GrappleTentacle.tscn
@export var strandScatter: float = 0.08        # aim spread in radians per extra strand
@export var pullSpeed: float = 300.0           # how hard the grapple reels you in
@export var pullStopDistance: float = 16.0     # stop pulling once this close

## vars
var extraStrands: Array[GrappleTentacle] = []   # spawned copies

## ===== FUNCTION OVERRIDES =====
func do_player_behavior(_delta:float):
	## === WEAPON CODE ===
	if inputHandler.is_action_just_pressed("Shoot"):
		weapon.request_shoot(host.get_forward())
	if inputHandler.is_action_just_pressed("Grapple"):
		if grapple.state == grapple.State.IDLE or grapple.state == grapple.State.RETRACTING:
			_fire_grapple()
		else:
			_detach_all()

func do_player_physics(_delta:float):
	## === MOVEMENT CODE ===
	var moveVector = inputHandler.get_move_input() ## retrieve normalized movement input vector from InputHandler
	# Apply movement
	host.velocity = moveVector * host.moveSpeed * GlobalDefs.MOVE_SPEED_CONST * _delta

	# === GRAPPLE PULL ===
	"""
	if grapple.is_pulling():
		var toAnchor := grapple.get_anchor() - host.global_position
		print("pulling, dist=", toAnchor.length(), " vel before=", host.velocity)
		if toAnchor.length() > pullStopDistance:
			host.velocity += toAnchor.normalized() * pullSpeed * 2
		print("vel after=", host.velocity)
	"""
	
	host.move_and_slide()
	

	# --- Rotation (face mouse) ---
	var aimPos = inputHandler.get_mouse_global_position()
	var lookDir = (aimPos - host.global_position).normalized()
	var targetDir = lookDir.angle()
	
	#inerpolate towards targetDirection
	host.global_rotation = lerp_angle(host.global_rotation, targetDir, host.rotationSpeed*_delta)
	

func on_posession()->void:
	pass
## ===== HELPER FUNCTIONS =====

func _fire_grapple() -> void:
	# prune any freed/finished strands from the previous shot
	extraStrands = extraStrands.filter(func(g): return is_instance_valid(g))
	for g in extraStrands:
		g.start_retract()        # retract any lingering ones before new fire
	extraStrands.clear()
	var n := randi_range(1, 10)
	for i in n:
		var g: GrappleTentacle = grapple
		var aim: Vector2 = host.get_forward()
		if i > 0:
			# extra strands: fresh instances that clean themselves up
			g = grappleScene.instantiate()
			get_parent().add_child(g)
			g.muzzle = grapple.muzzle
			g.freeOnDetach = true
			extraStrands.append(g)
			aim = aim.rotated(randf_range(-strandScatter, strandScatter))
		g.fire(host.global_position, aim, 400.0)

func _detach_all() -> void:
	grapple.start_retract()
	for g in extraStrands:
		if is_instance_valid(g):
			g.start_retract()
