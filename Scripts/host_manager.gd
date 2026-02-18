class_name HostManager
extends Node
## Hosts should all be children of this node

var hostArray:Array[Host]
var playerHost:Host
var EligibleHost:Host
var enemyTarget:Host

var cursor:Cursor

@onready var bloodManager := get_parent().find_child("bloodManager")

@onready var gameRunning:bool = true

@export var enemyConfusionDelay:float = 1.5
@onready var enemyConfusionTimer:float

@onready var maxTransferDistance: float = 250.0
@onready var maxTransferDistFromLook: float = 100.0

#ui refrence
@onready var player_camera: PlayerCamera = $PlayerCamera


#INTERMEDIATE
@onready var playerInSlither:bool = false
@onready var IntermediateScene:PackedScene = preload("res://Scenes/Host/slither_host.tscn")
@onready var slitherHost:SlitherHost = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	enemyConfusionTimer = enemyConfusionDelay
	cursor = find_child("Cursor")
	if cursor == null: printerr("Host Manager cannot find cursor")
	if bloodManager == null:printerr("Host manager cannot find blood manager")
	
	## Init Intermediate host
	slitherHost = IntermediateScene.instantiate()
	add_child(slitherHost)
	slitherHost.hide()
	
	## For testing slither movement (DELETE LATER)
	#playerHost = slitherHost
	#slitherHost.show()
	#playerInSlither = true
	#slitherHost.active = true
	#slitherHost.position = Vector2(-590.0, 180.0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#if playerHost!= null: print(playerHost.name)
	if hostArray.size()>1 or (playerInSlither and hostArray.size()>=1): checkForEligibleHost()
	enemyConfusionTimer-=delta
	if enemyConfusionTimer <= 0 and not enemyTarget == playerHost:
		enemyTarget = playerHost

## INTERMEDIATE FORM FUNCTIONS
func switchToIntermediateHost():
	player_camera.playTransferAudio(false)
	slitherHost.position = playerHost.position + (playerHost.global_transform.x.normalized() * slitherHost.summon_distance)
	slitherHost.global_rotation = playerHost.global_rotation
	slitherHost.show()
	playerHost.doSwitchAnim()
	playerHost.isPlayerControlled = false
	playerHost.stun(2.5)
	playerHost = slitherHost
	slitherHost.active = true
	playerInSlither = true
	enemyTarget = null
	enemyConfusionTimer = enemyConfusionDelay
	

func SwitchFromIntermediate():
	if EligibleHost != null: 
		#EligibleHost.projectileSpawner.forceReload()
		playerHost = EligibleHost
		slitherHost.active = false
		player_camera.playTransferAudio(true)
		slitherHost.doSwitchAnim()
		await slitherHost.possession_animation.animation_finished
		slitherHost.hide()
		
		playerHost.isPlayerControlled = true
		#enemy targeting
		enemyTarget = null
		enemyConfusionTimer = enemyConfusionDelay
		playerInSlither = false

func registerHost(host:Host):
	hostArray.append(host)
	#sig connection for ewach host
	host.died.connect(_on_host_died)
	
	if host.isPlayerControlled:
		host.died.connect(_on_host_died)

func switchHost(prev:Host, next:Host):
	if prev == null:
		printerr("Attempted Swap FROM null host")
		return
	elif next == null: 
		printerr("Attempted Swap TO null host")
		return
	
	print("Switching from: ", prev.name, " to ", next.name)
	prev.isPlayerControlled = false
	prev.stun(2.5)
	next.projectileSpawner.forceReload()
	playerHost = next
	
	next.isPlayerControlled = true
	enemyConfusionTimer = enemyConfusionDelay

func switchToEligibleHost():
	if EligibleHost != null:
		player_camera.playTransferAudio(true)
		playerHost.possession_animation.show()
		playerHost.possession_animation.play("default")
		await playerHost.possession_animation.animation_finished
		playerHost.possession_animation.stop()
		playerHost.possession_animation.hide()
		switchHost(playerHost, EligibleHost)
	else:
		player_camera.playTransferAudio(false)
		playerHost.possession_animation.show()
		playerHost.possession_animation.play("miss")
		await playerHost.possession_animation.animation_finished
		playerHost.possession_animation.stop()
		playerHost.possession_animation.hide()

func checkForEligibleHost():
	var minDist:float = 9999.0
	var closestHost:Host = null
	
	for host:Host in hostArray:
		var distToPlayerLookDir = distanceInFrontOfPlayer(playerHost.global_position, host.global_position)
		var distToPlayer = host.global_position.distance_to(playerHost.global_position)
		
		#var closeToLook:bool = distToPlayerLookDir < maxTransferDistFromLook
		var inFrontOfPlayer:bool = distToPlayerLookDir != -1
		var isNotPlayer: bool = host != playerHost
		var withinTransferDistance:bool = distToPlayer <= maxTransferDistance
		var isAlive:bool = host.alive
		var isStunned:bool = host.stunnedTimer>0
		
		var closestToLookSoFar:bool = distToPlayerLookDir < minDist
		
		if  inFrontOfPlayer and isNotPlayer and withinTransferDistance and closestToLookSoFar and isAlive and !isStunned:
			minDist = distToPlayerLookDir
			closestHost = host
	
	if EligibleHost == null and closestHost != null:
		EligibleHost = closestHost
		EligibleHost.transferMarker.visible = true
	elif closestHost == null and EligibleHost != null:
		EligibleHost.transferMarker.visible = false
		EligibleHost = null
	elif closestHost != EligibleHost: #if new eligible host found
		EligibleHost.transferMarker.visible = false
		EligibleHost = closestHost
		EligibleHost.transferMarker.visible = true

func distanceInFrontOfPlayer(playerPos:Vector2, targetPos:Vector2)->float:
	var player_dir = playerHost.global_transform.x.normalized()
	var to_target:Vector2 = targetPos - playerPos
	
	var projection = player_dir * (to_target.dot(player_dir) / player_dir.dot(player_dir))
	# Perpendicular vector
	var perp = to_target - projection
	
	var dot = player_dir.normalized().dot(to_target)
	if dot <= 0:
		# Target is behind the player
		return -1.0
	
	return perp.length()

#death signal listener
func _on_host_died(host: Host):
	await get_tree().create_timer(0.05).timeout
	bloodManager.spawnBlood(host.position)
	if host == playerHost:
		await get_tree().create_timer(0.75).timeout
		gameRunning = false
		player_camera.show_death_screen()
