## [WeaponHandler] – ABSTRACT class for weapon functionality
##
## [b]Responsibilities:[/b] [br]
##   - Core responsibility one [br]
##   - Core responsibility two [br]
class_name WeaponHandler extends Node

## ===== EXPORT VARIABLES =====
@export_category("References")
@export var projectileScene:PackedScene ## Packed Scene of projectile object [br] Root node must extend [Projectile]
@export var projectileSpawnPoint:Node2D

@export_category("Weapon Properties")
@export var damage:float = 1.0
@export var fire_rate:float = 0.1 ## Delay between shots in secconds
#@export var range:float = 10.0
@export var projectileSpeed:float = 1.0


## ===== SCRIPT VARIABLES =====
# ----- References -----
var host:HostController #set at runtime by HostController
var projectileParent:Node2D #retrieved via group

# ----- Timer -----
var shotDelayTimer:float = 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta): 
	if shotDelayTimer >= 0.0: shotDelayTimer -= _delta #tick down fire rate timer


## ===== CORE FUNCTIONS =====

## Creates an instance of provided projectile scene [br]
## [b]Expects:[/b] projectileScene and projectileSpawnPoint export variables to be set [br]
func instance_projectile(_dir:Vector2, _speed:float, _summonPos:Vector2, _dmg:float):
	var dir = _dir.normalized() #normalize direction just in case
	
	#Instantiate Projectile
	var proj:Projectile = projectileScene.instantiate()
	projectileParent.add_child(proj)
	
	#Set Intial position and rotation of projectile according to parameters
	proj.global_position = _summonPos
	proj.look_at(proj.global_position+dir)
	
	# Set Projectile member variables
	proj.direction = dir
	proj.damage = _dmg
	proj.speed = _speed
	proj.host = host


## Called by Enemy and Player Controller classes, and attempts to shoot if possible [br]
func request_shoot(_dir:Vector2)->void:
	if shotDelayTimer <= 0:
		fire_shot(_dir)
		shotDelayTimer = fire_rate

## ===== VIRTUAL FUNCTIONS TO BE OVERRIDEN =====

## [b]VIRTUAL[/b][br]
## Called: From request_shoot() if fire rate allows it [br]
## Handles: Unique weapon firing logic [br]
func fire_shot(_dir:Vector2)->void:pass