class_name ProjectileSpawner
extends Node2D

enum WeaponType{PISTOL, SHOTGUN}

var SpawnLocation:Vector2 = Vector2.ZERO
@onready var projectileParent:Node2D

@onready var muzzleFlash = $CPUParticles2D

@onready var projectile_scene: PackedScene = preload("res://Scenes/bullet.tscn")
@onready var audio:AudioStreamPlayer2D

@onready var camera:PlayerCamera

var shot_cooldown: float
var shot_timer: float = 0
var ammo:int = 0
var maxAmmo:int = 0
var reloadTime:float
var reloading:bool = false

var shotgun_flash_pos = Vector2(25.0, 7.333)
var pistol_flash_pos = Vector2(19.0, 5.333)

@onready var pistolAmmo:int = 6
@onready var shotgunAmmo:int = 2

@onready var pistolReload:float = 1.5
@onready var shotgunReload:float = 2.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	projectileParent = get_tree().current_scene.find_child("Projectile Parent")
	if projectileParent == null: printerr("Projectile Parent Not Found")
	
	
	await get_tree().process_frame
	camera = get_tree().current_scene.find_child("PlayerCamera")
#
	##if !camera:
		##printerr("cannot find cam")
	#
	#if !camera:
		#printerr("cannot find cam")
	#else: print(get_parent().get_parent().name," has camera ref")

	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	shot_timer -= delta
	#screen_shake(delta)


func shootPistol(direction: Vector2):
	if !canFire(): return
	
	var host = get_parent().get_parent() as Host
	#fixed so that player now cant reload (this was always unchecked it just worked before idk why)
	if ammo <= 0 and host.isPlayerControlled:
		return
	elif ammo <= 0 and !reloading: reload()
	if reloading: return
	shot_timer = shot_cooldown
	ammo-=1
	var p = projectile_scene.instantiate()
	projectileParent.add_child(p)
	
	# set variables and position
	p.source = get_parent().get_parent() #get host root node
	p.direction = direction.normalized()
	p.global_position = p.source.global_position
	p.global_rotation = direction.angle()
	
	#play shot audio
	audio.play()
	
	#play particle effect
	muzzleFlash.restart()

	camera.shake(5.0) # pistol

	#cam shake
	#add_shake(pistol_shake)

func shootShotgun(direction: Vector2, num_shots: int = 5, spread_degrees: float = 25.0):
	if !canFire(): return
	var host = get_parent().get_parent() as Host
	#fixed so that player now cant reload (this was always unchecked it just worked before idk why)
	if ammo <= 0 and host.isPlayerControlled:
		return
	elif ammo <= 0 and !reloading: reload()
	if reloading: return
	
	shot_timer = shot_cooldown
	ammo -= 1
	
	var source_node = get_parent().get_parent() # shooter root node
	
	for i in num_shots:
		var p = projectile_scene.instantiate()
		projectileParent.add_child(p)
		
		# Calculate spread
		var half_spread = spread_degrees * 0.5
		var random_angle = deg_to_rad(randf_range(-half_spread, half_spread))
		var pellet_dir = direction.normalized().rotated(random_angle)
		
		# Set projectile variables and position
		p.source = source_node
		p.direction = pellet_dir
		p.global_position = source_node.global_position
		p.global_rotation = pellet_dir.angle()
	
	# Play shot audio once
	audio.play()
	
	#play particle effect
	muzzleFlash.restart()
	camera.shake(15.0)

func canFire()->bool:
	return shot_timer<=0

func setupWeapon(weapon:WeaponType):
	if weapon == WeaponType.PISTOL:
		shot_cooldown = 0.15
		maxAmmo = pistolAmmo
		audio = $PistolAudio
		muzzleFlash.position = pistol_flash_pos
		reloadTime = pistolReload
		SpawnLocation = pistol_flash_pos
		
	elif weapon == WeaponType.SHOTGUN:
		shot_cooldown = 0.1
		maxAmmo = shotgunAmmo
		audio = $ShotgunAudio
		muzzleFlash.position = shotgun_flash_pos
		SpawnLocation = shotgun_flash_pos
		reloadTime = shotgunReload
	
	ammo = maxAmmo

func reload():
	reloading = true
	await get_tree().create_timer(reloadTime).timeout
	ammo = maxAmmo
	reloading = false

func forceReload():
	ammo = maxAmmo
