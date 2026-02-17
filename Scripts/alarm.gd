extends ColorRect
var t = 0

func _process(delta: float) -> void:
	t += delta
	color.a = lerp(0.0, 0.2, (sin( t * 5.0) + 1.0) * 0.5)
