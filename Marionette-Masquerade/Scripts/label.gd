extends Label

@export var shake_amount := 1.0			#pixels
@export var shake_speed := 0.01			#seconds per jitter

var base_position: Vector2
var shake_tween: Tween

func _ready():
	randomize()
	base_position = position
	#default idle shake
	shake_amount = 1.0
	shake_speed = 0.03
	start_shake()

func start_shake():
	if shake_tween:
		shake_tween.kill()

	shake_tween = create_tween()
	shake_tween.tween_callback(_shake_step)

func _shake_step():
	var offset := Vector2(
		randf_range(-shake_amount, shake_amount),
		randf_range(-shake_amount, shake_amount)
	)

	shake_tween = create_tween()
	shake_tween.tween_property(
		self,
		"position",
		base_position + offset,
		shake_speed
	)
	shake_tween.tween_callback(_shake_step)
