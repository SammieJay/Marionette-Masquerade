## [Hitbox] – A collider that is on collision mask 2 and only intersects with projectiles like bullets and hurtboxes
##
## [b]Responsibilities:[/b] [br]
##   - Detect when parent host should take damage [br]
class_name Hitbox extends Area2D

@export var autoSetPhysicsLayers:bool = true ## If true, hitbox will automatically override editor physics layer and mask settings at runtime

var host:HostController ## set by host controller at runtime

# Called when the node enters the scene tree for the first time.
func _ready():
	if autoSetPhysicsLayers:
		# Set collision masks (what this collider should check for physics collisions)
		set_collision_mask_value(GlobalDefs.LEVEL_PHYSICS_LAYER, false)
		set_collision_mask_value(GlobalDefs.HOST_PHYSICS_LAYER, false)
		set_collision_mask_value(GlobalDefs.HAZARD_PHYSICS_LAYER, false) # we want to detect overlap with hurtboxes and stage hazards (probably, currently does nothing) 6/8/2026
		set_collision_mask_value(GlobalDefs.HITBOX_PHYSICS_LAYER, false)

		# Set collision layer (what physics layer this collider lives on)
		set_collision_layer_value(GlobalDefs.LEVEL_PHYSICS_LAYER, false)
		set_collision_layer_value(GlobalDefs.HOST_PHYSICS_LAYER, false)
		set_collision_layer_value(GlobalDefs.HAZARD_PHYSICS_LAYER, false)
		set_collision_layer_value(GlobalDefs.HITBOX_PHYSICS_LAYER, true) # this Area2D lives on the hitbox layer


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

## Call hurt function of host
func hurt(_dmg:float):
	#print("HITBOX HIT")
	host.hurt(_dmg)