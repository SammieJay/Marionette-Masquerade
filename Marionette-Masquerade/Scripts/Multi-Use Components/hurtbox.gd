## [Hurtbox] – A collider that deals damage to any Hitbox it overlaps with
##
## [b]Responsibilities:[/b] [br]
##   - Lives on the Hazard physics layer, masks against Hitbox colliders [br]
##   - Calls hurt() on any Hitbox it detects, applying its own damage value [br]
class_name Hurtbox extends Area2D

enum HurtType {ONCE_PER_ENTRY, ONLY_ONCE, PERIODIC}

## How this Hurtbox applies damage [br]
## - ONCE_PER_ENTRY > default behavior - only hit once per overlap [br]
## - ONLY_ONCE > only hit each contacting hitbox once ever [br]
## - PERIODIC > tick damage - set tickInterval variable to set how often damage is applied [br]
@export var hurtType:HurtType = HurtType.ONCE_PER_ENTRY

#@export var onlyHitPlayer:bool = false ## Whether this hurtbox only affects player controlled Hosts (DOES NOT WORK YET)

@export var damage:float = 1.0

@export var startActive:bool = true

@export var autoSetPhysicsLayers:bool = true ## If true, hurtbox will automatically override editor physics layer and mask settings at runtime

@export_group("Lifespan Settings")
@export var temporary:bool = false ## If true this hurtbox will delete itself after 'lifespan' seconds
@export var lifespan:float = 10.0 ## If temporary variable is set to "true", hurtbox will disable itself after this much time
@export var clearAfterLifespan:bool = false ## Should we delete this hurtbox after it's lifespan
var lifespanTimer:float = 0.0

var host:HostController ## Optional - the host responsible for this damage source (e.g. weapon/attack owner), set at runtime if applicable

var active:bool = true


##  === Variables For Each HitType === ##
# -- ONLY_ONCE --
var alreadyHit:Array[Hitbox] = [] ## Array of every Hitbox hit by this Hurtbox for reference

# -- ONCE_PER_ENTRY -- #
# none required

# -- PERIODIC -- #
@export_group("Tick Damage Settings")
@export var tickInterval: float = 0.5 ## How often (in seconds) damage is applied to hitboxes currently inside this Hurtbox

var overlappingHitboxes:Array[Hitbox] = []
var tickTimer:float = 0.0


func get_overlapping_hitboxes()->Array[Hitbox]: 
	if active: return overlappingHitboxes ## Returns list of hitboxes currently inside this hurtbox
	else: return []

# Called when the node enters the scene tree for the first time.
func _ready():
	active = startActive

	if autoSetPhysicsLayers:
		# Set collision masks (what this collider should check for physics collisions)
		set_collision_mask_value(GlobalDefs.LEVEL_PHYSICS_LAYER, false)
		set_collision_mask_value(GlobalDefs.HOST_PHYSICS_LAYER, false)
		set_collision_mask_value(GlobalDefs.HAZARD_PHYSICS_LAYER, false)
		set_collision_mask_value(GlobalDefs.HITBOX_PHYSICS_LAYER, true) # we want to detect overlap with Hitboxes

		# Set collision layer (what physics layer this collider lives on)
		set_collision_layer_value(GlobalDefs.LEVEL_PHYSICS_LAYER, false)
		set_collision_layer_value(GlobalDefs.HOST_PHYSICS_LAYER, false)
		set_collision_layer_value(GlobalDefs.HAZARD_PHYSICS_LAYER, true) # this Area2D lives on the hazard layer
		set_collision_layer_value(GlobalDefs.HITBOX_PHYSICS_LAYER, false)

	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

func _process(_delta:float):
	if !active: return

	if temporary and active:
		lifespanTimer += _delta
		if lifespanTimer >= lifespan:
			if clearAfterLifespan: queue_free()
			else: deactivate()
			lifespanTimer -= lifespan

	match hurtType:
		HurtType.ONCE_PER_ENTRY:
			pass
		HurtType.ONLY_ONCE:
			pass
		HurtType.PERIODIC:
			if overlappingHitboxes.is_empty(): return
			tickTimer += _delta
			if tickTimer >= tickInterval:
				tickTimer -= tickInterval
				apply_tick_damage()

## Called whenever another Area2D enters this hurtbox's area
func _on_area_entered(_area:Area2D):
	var hitbox := _area as Hitbox
	if !hitbox: return
	overlappingHitboxes.append(hitbox)
	if !active: return

	match hurtType:
		HurtType.ONCE_PER_ENTRY:
			hitbox.hurt(damage)
		HurtType.ONLY_ONCE:
			if hitbox in alreadyHit: return
			hitbox.hurt(damage)
			alreadyHit.append(hitbox)
		HurtType.PERIODIC:
			pass

func _on_area_exited(_area:Area2D):
	var hitbox := _area as Hitbox
	if !hitbox: return

	overlappingHitboxes.erase(hitbox)

func deactivate():
	active = false
	reset_hits()
	tickTimer = 0.0

func activate(): ## Called by other classes, mainly used for reactivation of this hurtbox (for things like weapons)
	active = true
	reset_hits()
	if lifespanTimer >= lifespan:
		lifespan = 0.0



## ===== HURT TYPE SPECIFIC FUNCITONS ===== ##

## Damages every currently-tracked Hitbox, skipping any that were freed since last tick
func apply_tick_damage():
	for hitbox in overlappingHitboxes:
		if !is_instance_valid(hitbox): continue
		hitbox.hurt(damage)

## Clears the hurtOnce record, allowing this hurtbox to damage previously-hit Hitboxes again
func reset_hits()->void:
	alreadyHit.clear()