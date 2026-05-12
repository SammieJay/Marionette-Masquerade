## [Weapon] – ABSTRACT class for weapon functionality
##
## [b]Responsibilities:[/b] [br]
##   - Base class for all weapon classes [br]
##   - Core responsibility two [br]
class_name Weapon extends Node

## ===== EXPORT VARIABLES =====
@export_category("References")
@export var projectileScene:PackedScene ## Packed Scene of projectile object [br] Root node must extend [Projectile]

@export_category("Weapon Properties")
@export var damage:float = 1.0
@export var fire_rate:float = 0.1 ## Delay between shots in secconds
@export var projectileSpeed:float = 1200.0
@export var projectileSpawnForwardOffset:float = 10.0
@export var maxAmmo:int = 12
@export var reloadTime:float = 2.0 ## Time it takes to reload in secconds


## ===== SCRIPT VARIABLES =====
# ----- References -----
var host:HostController #set at runtime by HostController
var projectileParent:Node2D #retrieved via group
var ammo:int

## Runs Timer for Reload [br]
## - if reloadTimer > 0 -> weapon is reloading [br]
## - if reloadTimer < 0 -> weapon is done reloading [br]
## - if reloadTimer == 0 -> weapon is ready to fire [br]
var reloadTimer:float 

# ----- Timer -----
var shotDelayTimer:float = 0.0

## ===== BOOLEAN RETURN FUNCITONS =====
func is_reloading()->bool: return reloadTimer > 0.0

## MUST BE CALLED FROM INHERITING CLASSES VIA 'super._ready()'
## Performs mandatory setup for the Weapon class
func _ready():
	projectileParent = get_tree().get_first_node_in_group("ProjectileParent")
	ammo = maxAmmo

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if shotDelayTimer >= 0.0: shotDelayTimer -= _delta #tick down fire rate timer
	if reloadTimer > 0.0: reloadTimer -= _delta # tick down reload timer

	if reloadTimer < 0.0:
		reloadTimer = 0.0
		ammo = maxAmmo


## ===== CORE FUNCTIONS =====

## Creates an instance of provided projectile scene [br]
## [b]Expects:[/b] projectileScene and projectileSpawnPoint export variables to be set [br]
func instance_projectile(_dir:Vector2, _speed:float, _dmg:float):
	ammo -= 1
	
	var dir = _dir.normalized() #normalize direction just in case
	
	#Instantiate Projectile
	var proj:Projectile = projectileScene.instantiate()
	projectileParent.add_child(proj)
	
	#Set Intial position and rotation of projectile according to parameters
	proj.global_position = host.global_position + host.get_look_vector() * projectileSpawnForwardOffset
	proj.look_at(proj.global_position+dir)
	
	# Set Projectile member variables
	proj.direction = dir
	proj.damage = _dmg
	proj.speed = _speed
	proj.host = host


## Called by Enemy and Player Controller classes, and attempts to shoot if possible [br]
func request_shoot(_dir:Vector2)->void:
	if shotDelayTimer <= 0 and ammo > 0:
		fire_shot(_dir)
		shotDelayTimer = fire_rate

## Called by whenever gun must be reloaded, parameter takes a reload time but defaults to given variable [br]
func reload(_reloadTime:float = reloadTime):
	reloadTimer = _reloadTime


## ===== VIRTUAL FUNCTIONS TO BE OVERRIDEN =====

## [b]VIRTUAL[/b][br]
## Called: From request_shoot() if fire rate allows it [br]
## Handles: Unique weapon firing logic [br]
func fire_shot(_dir:Vector2)->void:pass
