## [HostManager] – Class handles the logic behind when the player can posess a new host, and which host the player can swap to
##
## [b]Responsibilities:[/b] [br]
##   - Select an elegible host for the player to switch to [br]
##   - Instruct the relevent classes to do logic when the player makes a switch input [br]
class_name HostManager extends Node

@export_category("Required References")
@export var startingPlayerHost:HostController



## ===== SCRIPT VARIABLES =====

#@onready var gameRunning:bool = true
@onready var inputHandler:InputHandler
@onready var possessionIndicator:PossessionIndicator
@onready var cursor:Cursor

@onready var playerHost:HostController
@onready var eligibleHost:HostController

var hostArray:Array[HostController]

var maxTransferDistFromLook: float = 75.0
const MAX_TRANSFER_DISTANCE:float = 100.0 ## Maximum distance that player can transfer to a new host in

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Initialize required nodes
	inputHandler = get_tree().get_first_node_in_group("InputHandler") # Retrieve InputHandler refrence from global group
	possessionIndicator = get_tree().get_first_node_in_group("PossessionIndicator") # Retrieve PossessionIndicator refrence from global group
	cursor = get_tree().get_first_node_in_group("Cursor")

	_verify_core_references()
	
	_refresh_host_array()

	# Initialize starting host
	playerHost = startingPlayerHost
	playerHost.possess()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if !playerHost.is_possessed(): playerHost.currentlyPossessed = true # Redundantly ensure that the palyerHost is allways in a posessed state
	eligibleHost = _check_for_switchable_host()
	possessionIndicator.set_target(eligibleHost)

	# Check for player input to switch hosts
	if inputHandler.is_action_just_pressed("Transfer Hosts"):
		if eligibleHost != null: switch_to_host(eligibleHost)
		else: playerHost.effectHandler.play_switch_effect(false)


## Instructs relevent HostController classes to update possession status [br]
## [b]Expects:[/b] a non-null parameter input [br]
func switch_to_host(next:HostController):
	#print("HOST SWITCH")
	playerHost.un_possess()
	playerHost = next
	playerHost.possess()


## ===== HELPER FUNCTIONS =====

## refresh array of hosts to only include living hosts
func _refresh_host_array()->void:
	hostArray.clear()
	var hostGroup:Array[Node] = get_tree().get_nodes_in_group("Host")
	for node:Node in hostGroup:
		var host = node as HostController
		if host != null: 
			hostArray.append(host)
	
	#print("Num Hosts: %d" % hostArray.size())

## Returns a host that the player host is eligible to switch to, if there is none, returns null
## TODO clean this function up
func _check_for_switchable_host()->HostController:
	if hostArray.size() == 0:
		#print("NO HOSTS IN ARRAY")
		return null
	var minDist:float = 9999.9
	var closestHost:HostController = null
	
	for host:HostController in hostArray:
		if host == null: continue
		var distToPlayerLookDir = _distanceInFrontOfPlayer(playerHost.global_position, host.global_position)
		var distToPlayer = host.global_position.distance_to(playerHost.global_position)
		var distToCursor = host.global_position.distance_to(cursor.global_position)
		
		var closeToLook:bool = distToPlayerLookDir < maxTransferDistFromLook
		var inFrontOfPlayer:bool = distToPlayerLookDir != -1
		var isNotPlayer: bool = host != playerHost
		var withinTransferDistance:bool = distToPlayer <= MAX_TRANSFER_DISTANCE + playerHost.possessionReach
		var isAlive:bool = host.is_alive()
		var isStunned:bool = host.enemyController.is_stunned()
		
		## Is this the currently closest host so far
		var closestSoFar:bool = distToCursor < minDist
		
		if withinTransferDistance and closestSoFar and inFrontOfPlayer and isNotPlayer and isAlive and !isStunned and closeToLook:
			minDist = distToCursor
			closestHost = host
	
	if !closestHost: return null
	
	var distToPlayer2 = closestHost.global_position.distance_to(playerHost.global_position)
	
	if distToPlayer2 > MAX_TRANSFER_DISTANCE + playerHost.possessionReach: 
		print("IM too far and something is broken")
	
	return closestHost

## a complicated distance return helper function
## TODO rename and clarify this function
func _distanceInFrontOfPlayer(playerPos:Vector2, targetPos:Vector2)->float:
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

func _verify_core_references()->void:
	assert(startingPlayerHost != null, "HostManager has no set starting Host")
	assert(possessionIndicator != null, "HostManager requires a PossessionIndicator in the scene")
	assert(inputHandler != null, "HostManager could not find InputHandler from global group")
	assert(cursor != null, "HostManager could not find Cursor from global group")
