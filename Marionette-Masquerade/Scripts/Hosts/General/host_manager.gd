class_name HostManager extends Node

var hostArray:Array[HostController]
var playerHost:HostController

var cursor:Cursor

@export_category("Required References")
@export var startingPlayerHost:HostController


## ===== SCRIPT VARIABLES =====

@onready var gameRunning:bool = true
#@onready var maxTransferDistance: float = 250.0
#@onready var maxTransferDistFromLook: float = 100.0
#@onready var player_camera: PlayerCamera

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	cursor = get_tree().get_first_node_in_group("Cursor")
	_refresh_host_array()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if hostArray.size()>1: checkForEligibleHost()


## ===== HELPER FUNCTIONS =====

## refresh array of hosts
func _refresh_host_array()->void:
	hostArray = get_tree().get_nodes_in_group("Host") as Array[HostController]
































func switchHost(prev:HostController, next:HostController):
	prev.isPlayerControlled = false
	prev.stun(2.5)
	
	next.projectileSpawner.forceReload()
	playerHost = next
	
	next.isPlayerControlled = true

func checkForEligibleHost():
	var minDist:float = 9999.0
	var closestHost:HostController = null
	
	for host:HostController in hostArray:
		var distToPlayerLookDir = distanceInFrontOfPlayer(playerHost.global_position, host.global_position)
		var distToPlayer = host.global_position.distance_to(playerHost.global_position)
		
		#var closeToLook:bool = distToPlayerLookDir < maxTransferDistFromLook
		var inFrontOfPlayer:bool = distToPlayerLookDir != -1
		var isNotPlayer: bool = host != playerHost
		var withinTransferDistance:bool = distToPlayer <= playerHost.MAX_TRANSFER_DISTANCE
		var isAlive:bool = host.alive
		var isStunned:bool = host.stunnedTimer>0
		
		var closestToLookSoFar:bool = distToPlayerLookDir < minDist
		
		if  inFrontOfPlayer and isNotPlayer and withinTransferDistance and closestToLookSoFar and isAlive and !isStunned:
			minDist = distToPlayerLookDir
			closestHost = host
	

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