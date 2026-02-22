class_name Host
extends CharacterBody2D

signal died(host)

enum weaponType {UNARMED, PISTOL, SHOTGUN}
@export var activeWeapon:weaponType = weaponType.UNARMED

@export var isPlayerControlled = false
@export var move_speed: float = 300.0
@export var look_speed: float = 10.0

## References
@onready var hostManager:HostManager
@onready var projectileSpawner: ProjectileSpawner = $"Weapon/Projectile Spawner"
@onready var collider:CollisionShape2D = $CollisionShape2D

#sprite References
@onready var bodySprite:AnimatedSprite2D = $Body
@onready var playerMarker:AnimatedSprite2D = $MaskSprite
@onready var transferMarker:AnimatedSprite2D = $"Target Sprite"
@onready var pistolSprite:AnimatedSprite2D = $"Weapon/Pistol Sprite"
@onready var shotgunSprite:AnimatedSprite2D = $"Weapon/Shotgun Sprite"
@onready var corpseSprite:AnimatedSprite2D = $"Corpse Sprite"
@onready var stunSprite:AnimatedSprite2D = $"Stun Effect Sprite"
@onready var legSprite:AnimatedSprite2D = $"Leg Sprite"

## Audio Refs
@onready var footstepAudio:AudioStreamPlayer2D = $FootstepAudio

@onready var alive:bool = true

## AI SPECIFIC VARIABLES
enum EnemyState{IDLE, CHASE}
var enemyState:EnemyState = EnemyState.IDLE
#Attack
@export var ShootDistance = 200.0
@export var shootDelay = 0.3
@onready var shootDelayTimer:float
@onready var shooting:bool = false
@onready var stunnedTimer:float = 0
#Vision
@export var visionRange = 450.0
@export var visionFogAngle = 70
@export var loseSightDistance = 600.0
#Idle Behavior
@onready var idle_look_interval = 2.5
@onready var idle_look_anlge_deg = 60.0
#Chase Behavior
@onready var enemy_move_speed:float = 200.0

@onready  var target:Host
@onready var navAgent:NavigationAgent2D = $"Navigation Agent"
@onready var visionRay:RayCast2D = $"Vision Ray"

var idleTimer = 0.0
var lookTargetRotation = 0.0

@export var enemyAI_enabled:bool = true

#anim vaar
@onready var possession_animation = $MaskSprite/possess_anim



func _ready():
	if playerMarker == null: printerr("Host cannot find player marker")
	if transferMarker == null: printerr("Host cannot find transfer marker")
	hostManager = get_parent()
	hostManager.registerHost(self)
	
	if isPlayerControlled: 
		hostManager.playerHost = self
		hostManager.enemyTarget = self
	weaponSetup()

func _process(delta: float) -> void:
	if (stunnedTimer<=0 or isPlayerControlled or !alive) and stunSprite.visible == true: 
		stunSprite.hide()
	
	if !hostManager.gameRunning: return
	
	if velocity.length()>0 && alive: 
		walkingAnim(delta)
	else:
		if legSprite.visible == true: legSprite.hide()
		if footstepAudio.playing == true: footstepAudio.stop()
	
	# --- Movement ---
	if isPlayerControlled and alive:
		playerMarker.visible = true
		target = null
		doPlayerMovement(delta)
	elif alive:
		playerMarker.visible = false
		target = hostManager.enemyTarget
		if enemyAI_enabled: doEnemyBehavior(delta)
		shootDelayTimer -= delta

func _input(event: InputEvent) -> void:
	## PLAYER CONTROLS
	if isPlayerControlled and alive:
		if event.is_action_pressed("Transfer Hosts"):
			
			hostManager.switchToEligibleHost()
		if event.is_action_pressed("Shoot"):
			shootWeapon()
			

func doPlayerMovement(delta: float):
	var input_vector := Input.get_vector("Move Left","Move Right","Move Up","Move Down")
	if input_vector.length() > 0: input_vector = input_vector.normalized()
	
	velocity = input_vector * move_speed
	move_and_slide()

	# --- Rotation (face mouse) ---
	var aimPos = get_global_mouse_position()
	var direction = (aimPos - global_position).normalized()
	var targetDirection = direction.angle()
	
	#inerpolate towards targetDirection
	global_rotation = lerp_angle(global_rotation, targetDirection, look_speed*delta)
	
	
	#look_at(get_global_mouse_position())

func shootWeapon():
	var original_pos_p = pistolSprite.position
	var original_pos_s = shotgunSprite.position
	
	var shootDirection:Vector2 = transform.x.normalized()
	
	if activeWeapon == weaponType.PISTOL:
		projectileSpawner.shootPistol(shootDirection)
		var tween = create_tween()
		tween.tween_property(pistolSprite, "position", original_pos_p + Vector2(-4,0), 0.1)
		tween.tween_property(pistolSprite, "position", original_pos_p, 0.05)
	if activeWeapon == weaponType.SHOTGUN:
		projectileSpawner.shootShotgun(shootDirection)
		var tween = create_tween()
		tween.tween_property(shotgunSprite, "position", original_pos_s + Vector2(-5,0), 0.1)
		tween.tween_property(shotgunSprite, "position", original_pos_s, 0.05)
		
	if !isPlayerControlled:
		shootDelayTimer = shootDelay
		
func weaponSetup():
	## UNARMED SETUP
	if activeWeapon == weaponType.UNARMED:
		shotgunSprite.hide()
		pistolSprite.hide()
	
	## PISTOL SETUP
	elif activeWeapon == weaponType.PISTOL:
		#Sprite
		shotgunSprite.hide()
		pistolSprite.show()
		
		#Projectile Spawner
		projectileSpawner.setupWeapon(0)
	
	## SHOTGUN SETUP
	elif activeWeapon == weaponType.SHOTGUN:
		#sprite
		shotgunSprite.show()
		pistolSprite.hide()
		
		#Projectile Spawner
		projectileSpawner.setupWeapon(1)

func die():
	if !alive:
		return

	alive = false
	if !isPlayerControlled:
		corpseSprite.frame = 0
	else:
		corpseSprite.frame = 1
	
	footstepAudio.stop()
	corpseSprite.show()
	bodySprite.hide()
	legSprite.stop()
	legSprite.hide()
	playerMarker.hide()
	transferMarker.hide()
	shotgunSprite.hide()
	pistolSprite.hide()
	collider.set_deferred("disabled", true)
	z_index -= 2
	emit_signal("died", self)

## ===== AI FUNCTIONS =====
func doEnemyBehavior(delta:float):
	if stunnedTimer > 0: 
		doStunEffect(delta)
		return
	match enemyState:
		EnemyState.IDLE:
			enemy_idle(delta)
		EnemyState.CHASE:
			enemy_chase(delta)


func canSeePlayer()->bool:
	if target == null: return false
	var to_target = target.global_position - global_position
	var dist_to_target = to_target.length()
	
	if dist_to_target <= visionRange: 
		#print("Player is close enough to see")
		return true
	
	var forward = transform.x.normalized()
	var angle_to_target = rad_to_deg(forward.angle_to(to_target))
	
	if(abs(angle_to_target) > visionFogAngle * 0.5):return false
	
	#line of sight check
	visionRay.target_position = to_target
	visionRay.force_raycast_update()
	
	if visionRay.get_collider() != target.collider:
		return false
	
	return true

func enemy_chase(delta:float):
	if target == null:
		enter_idle()
		return
	
	var dist_to_target = global_position.distance_to(target.global_position)
	
	if dist_to_target > loseSightDistance:
		enter_idle()
		return
	

	
	navAgent.target_position = target.global_position
	
	var next_pos = navAgent.get_next_path_position()
	var dir = (next_pos - global_position).normalized()
	
	velocity = dir * enemy_move_speed
	move_and_slide()
	if dist_to_target < ShootDistance and canSeePlayer():
		look_at_target(delta)
		shootAfterDelay(delta)
	elif canSeePlayer():
		look_at_target(delta)
	else: 
		shooting = false
		rotation = lerp_angle(rotation, dir.angle(), 8.0*delta)
	
func enemy_idle(delta:float):
	velocity = Vector2.ZERO
	move_and_slide()
	
	idleTimer -= delta
	if idleTimer < 0.0:
		idleTimer = idle_look_interval
		var angle = deg_to_rad(randf_range(-idle_look_anlge_deg, idle_look_anlge_deg))
		lookTargetRotation = rotation + angle
	
	rotation = lerp_angle(rotation, lookTargetRotation, 2.0*delta)
	
	if canSeePlayer():
		enter_chase()

## Enemy State Machine Functions
func enter_chase(): enemyState = EnemyState.CHASE

func enter_idle():
	enemyState = EnemyState.IDLE
	idleTimer = idle_look_interval

func look_at_target(delta:float):
	var dir = (target.global_position - global_position).normalized()
	global_rotation = lerp_angle(global_rotation, dir.angle(), 6.0 * delta)

func shootAfterDelay(delta:float):
	# player shouldn't be restricted by AI timers
	if isPlayerControlled:
		return 
	if !shooting:
		shootDelayTimer = shootDelay
		shooting = true
	else:
		shootDelayTimer-=delta
		if shootDelayTimer <=0:
			shootWeapon()

func stun(durration:float):
	stunnedTimer = durration

func doStunEffect(delta:float):
	if stunSprite.visible == false: stunSprite.show()
	stunnedTimer-= delta
	stunSprite.rotation+=delta*4.0

func walkingAnim(delta:float):
	if legSprite.visible == false: legSprite.show()
	elif !footstepAudio.playing: footstepAudio.play()
	legSprite.look_at(global_position+velocity)
	legSprite.rotation_degrees+=90
