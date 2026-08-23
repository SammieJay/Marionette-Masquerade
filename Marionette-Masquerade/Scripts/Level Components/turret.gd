extends Node2D

enum State { ASLEEP, WAKING, IDLE, SHOOTING }
var state: State = State.ASLEEP

@export var shoot_cooldown: float = 0.6
var cooldown_timer: float = 0.0

func _ready() -> void:
	$sprite.play("idle")
	$RayCast2D.collide_with_areas = true
	$RayCast2D.collision_mask = 0 # clear it first
	$RayCast2D.set_collision_mask_value(2, true) # replace with the real layer

func _process(delta: float) -> void:
	if cooldown_timer > 0.0:
		cooldown_timer -= delta
	print("state: ", state, " colliding: ", $RayCast2D.is_colliding())
	match state:
		State.ASLEEP:
			if $RayCast2D.is_colliding():
				state = State.WAKING
				$sprite.play("wakeup")
				await $sprite.animation_finished
				state = State.IDLE
				$sprite.play("wakeup_idle")

		State.IDLE:
			if $RayCast2D.is_colliding():
				state = State.SHOOTING
				_fire()

		State.SHOOTING:
			if not $RayCast2D.is_colliding():
				# target left the raycast, go back to idle
				state = State.IDLE
				$sprite.play("wakeup_idle")
			elif cooldown_timer <= 0.0:
				# still colliding and cooldown's up — shoot again
				_fire()

func _fire() -> void:
	$sprite.play("shoot")
	cooldown_timer = shoot_cooldown

	var target: Node2D = $RayCast2D.get_collider()
	if target and target.has_method("take_damage"):
		target.take_damage(1) # adjust damage amount as needed

	await $sprite.animation_finished
	# if still in SHOOTING state (didn't get interrupted), settle into an idle-ish pose
	if state == State.SHOOTING:
		$sprite.play("wakeup_idle") # or a "shoot_idle" frame if you have one
