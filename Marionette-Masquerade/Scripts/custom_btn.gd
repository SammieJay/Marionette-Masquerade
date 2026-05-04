extends Node2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var area: Area2D = $Area2D
@onready var label: Label = $Label

@export var lbl_txt := "dflt text":
	set(value):
		lbl_txt = value
		if is_node_ready():
			label.text = value

@export var target_scene: PackedScene	#assignable scene in inspector

@export var shake_amount := 1.0			#pixels
@export var shake_speed := 0.01			#seconds per jitter

signal pressed

var base_scale: Vector2
var hover_scale := Vector2(1.1, 1.1)

var base_position: Vector2

var pulse_tween: Tween
var scale_tween: Tween
var shake_tween: Tween

func _ready():
	get_tree().paused = false
	randomize()
	base_scale = scale
	base_position = position
	label.text = lbl_txt

	area.mouse_entered.connect(_on_mouse_entered)
	area.mouse_exited.connect(_on_mouse_exited)
	area.input_event.connect(_on_input_event)
	
	#default idle shake
	shake_amount = 1.0
	shake_speed = 0.01
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

func _on_mouse_entered():
	shake_amount = 3.0
	shake_speed = 0.001
	start_shake()
	#enlarge
	scale_tween = create_tween()
	scale_tween.tween_property(self, "scale", hover_scale, 0.15)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)

	#red pulse
	pulse_tween = create_tween()
	pulse_tween.set_loops()
	pulse_tween.tween_property(sprite, "modulate", Color(1, 0.3, 0.3), 0.4)
	pulse_tween.tween_property(sprite, "modulate", Color.WHITE, 0.4)

func _on_mouse_exited():
	shake_amount = 1.0
	shake_speed = 0.01
	start_shake()
	
	if pulse_tween:
		pulse_tween.kill()

	create_tween().tween_property(self, "scale", base_scale, 0.15)
	create_tween().tween_property(self, "position", base_position, 0.1)

	sprite.modulate = Color.WHITE

func _on_input_event(viewport, event, _shape_idx):
	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and event.pressed:
		emit_signal("pressed")
		_click_flash_and_go()

func _click_flash_and_go():
	get_tree().paused = false
	#stop hover pulse
	if pulse_tween:
		pulse_tween.kill()

	var strobe_tween := create_tween()

	#strobe effect (0.2s total)
	var flashes := 5
	var step := 0.2 / (flashes * 2)

	for i in flashes:
		strobe_tween.tween_property(sprite, "modulate", Color.WHITE, step)
		strobe_tween.tween_property(sprite, "modulate", Color(1, 0.3, 0.3), step)

	await strobe_tween.finished
	
	sprite.modulate = Color.WHITE

	if target_scene:
		get_tree().change_scene_to_packed(target_scene)
	else:
		get_tree().reload_current_scene()
