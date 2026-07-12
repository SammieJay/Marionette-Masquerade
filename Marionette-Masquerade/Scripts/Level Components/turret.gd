extends Node2D

enum State { ASLEEP, WAKING, IDLE, SHOOTING }
var state: State = State.ASLEEP

func _ready() -> void:
	$sprite.play("idle")

func _process(delta: float) -> void:
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
				$sprite.play("shoot")

		State.SHOOTING:
			# decide what happens after shooting — loop shoot animation,
			# go back to idle, wait for animation_finished, etc.
			pass
