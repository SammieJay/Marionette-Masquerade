class_name PlayerCamera
extends Camera2D

var target:Host
@onready var hostManager:HostManager



# shader stuff
@onready var deathShader = $deathShader
@onready var shader = $speedLineShader
@export var pulse_speed := 4.0
@export var min_alpha := 0.15
@export var max_alpha := 1.0
var pulse_time := 0.0

## Editable variables
@export var TrackingStrength:float = 2.0

# shake stuff
@export var shake_fade = 30.0
var shake_amnt = 0.0

#sound 
@onready var music = $gameSound
@onready var maskTransferSound:AudioStreamPlayer2D = $MaskTrasferAudio
@onready var maskTransferMissSound:AudioStreamPlayer2D = $MaskTrasferAudioMiss

#game over stuff and buttons
@onready var gameover_btns = $gameover_btns
@onready var menu_btn = $gameover_btns/menu
@onready var restart_btn = $gameover_btns/restart
@onready var gameoverLbl = $gameOver_lbl

#stuff you hide on game over
@onready var spotlight = $spotlightShader
@onready var ammoLbl = $"ammo count"
@onready var ammoLbl2 = $Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hostManager = get_tree().current_scene.find_child("HostManager")
	if hostManager == null: printerr("camera cannot find Host Manager")
	# shader
	shader.material = shader.material.duplicate()
	# starts music
	music.play()
	
	#listeners setup
	restart_btn.pressed.connect(_on_restart_button_pressed)
	menu_btn.pressed.connect(_on_menu_button_pressed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if shake_amnt > 0:
		shake_amnt = max(shake_amnt - shake_fade * delta, 0)
		offset = Vector2(randf_range(-shake_amnt, shake_amnt), randf_range(-shake_amnt, shake_amnt))
	else:
		offset = Vector2.ZERO
	
	#shader stuff
	if shake_amnt > 0:
		pulse_time += delta * pulse_speed
		#sharper pulse curve
		var t: float = pow((sin(pulse_time) + 1.0) * 0.5, 2.0)
		var alpha: float = lerp(min_alpha, max_alpha, t)
		(shader.material as ShaderMaterial)\
			.set_shader_parameter("pulse_alpha", alpha)
	else:
		(shader.material as ShaderMaterial)\
			.set_shader_parameter("pulse_alpha", 0.0)
	
	
	var tempTaget = hostManager.playerHost
	if tempTaget != null:
		target = tempTaget
	
	trackTarget(delta)
	
	if !hostManager.playerInSlither: 
		updateAmmoLabel()

func trackTarget(delta:float):
	var targetPos: Vector2 = target.global_position
	global_position = global_position.lerp(
		targetPos,
		TrackingStrength*delta
	)
	rotation = 0.03

func updateAmmoLabel():
	ammoLbl.text = str(hostManager.playerHost.projectileSpawner.ammo)

func shake(amount: float) -> void:
	shake_amnt = max(shake_amnt, amount)
	
func show_death_screen():
	deathShader.show()
	gameover_btns.show()
	gameoverLbl.show()
	restart_btn.show()
	menu_btn.show()
	#stuff you hide on game over
	spotlight.hide()
	ammoLbl.hide()
	ammoLbl2.hide()
	Score.resetStage()


func _on_restart_button_pressed():
	get_tree().reload_current_scene()
	Score.resetStage()
	
func _on_menu_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/title_screen.tscn")

func playTransferAudio(hit:bool):
	if hit: maskTransferSound.play()
	else: maskTransferMissSound.play()
