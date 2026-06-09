## [Projectile] – Root node for all projectile instances
##
## [b]Responsibilities:[/b] [br]
##	 - Moves projectile at set velocity[br]
##	 - Contains information about who emited the projectile and how much dmg it does[br]
##	 - Informs Hitboxes when a collision hit has occured[br]
class_name Projectile extends Area2D

var damage:float
var direction:Vector2
var speed:float
var host:HostController ## the host that created this projectile

var active:bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

	## Set Collision Mask (what this Area2D checks for when colliding)
	set_collision_mask_value(GlobalDefs.LEVEL_PHYSICS_LAYER, true) # check for intersections with level geometry
	set_collision_mask_value(GlobalDefs.HOST_PHYSICS_LAYER, false)
	set_collision_mask_value(GlobalDefs.HAZARD_PHYSICS_LAYER, false)
	set_collision_mask_value(GlobalDefs.HITBOX_PHYSICS_LAYER, true) # check for intersections with hitboxes

	## Set Collision Layer (That physics layer this object lives on)
	set_collision_layer_value(GlobalDefs.LEVEL_PHYSICS_LAYER, false)
	set_collision_layer_value(GlobalDefs.HOST_PHYSICS_LAYER, false)
	set_collision_layer_value(GlobalDefs.HAZARD_PHYSICS_LAYER, true) # Projectiles live on the hazard level
	set_collision_layer_value(GlobalDefs.HITBOX_PHYSICS_LAYER, false)

	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if active: global_position += direction * speed * delta

## Check for collision with physics bodies (environment) - Just delete if we collide with environment
func _on_body_entered(body):
	# Return early if we are colliding with our own colliders - should be redundant if physics mask is set propperly
	if body == host:return
	
	#print("Hit On ", body.name)
	
	active = false
	queue_free()

func _on_area_entered(area):
	# Return early if we are colliding with the source's hitbox
	if area == host.hitbox: return

	if area is Hitbox and area.host.is_alive():
		
		if active: (area as Hitbox).hurt(damage)
		
		#print("HIT DETECTED WITH %s" % area.name)
	
	#print("Hit On ", area.name)

	active = false
	queue_free()
	
