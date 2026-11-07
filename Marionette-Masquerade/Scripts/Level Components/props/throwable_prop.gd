## [ThrowableProp] – Root node for interactable and movable objects like barrels and crates
##
## [b]Responsibilities:[/b] [br]
##   - Handle logic for object health and on collision logic for non-host objects [br]
##	 - Explosion Logic [br] 
class_name ThrowableProp extends CharacterBody2D

@export var body:ImpulseBody ## The impulse body for this object
@export var hitbox:Hitbox ## hitbox

@export_group("Explosion Settings")
@export var explodeOnImpact:bool = false
@export var explodeOnHit:bool = false
@export var explosionHurtbox:Hurtbox
@export var explosionImpulse:float = 5.0
@export var explosionDamage:float = 0.75
var hasExploded:bool = false

#@export_range(0.0,5.0,0.01) var impulseDistanceScalar:float = 1.0
@export var explosionAnimation:AnimationPlayer # TODO: replace this animation player with effect handler

func _ready():
	body.impact.connect(on_impact)
	if is_instance_valid(hitbox):
		hitbox.on_hit.connect(on_hit)# connect on hit signal


func _process(_delta:float):
	## TODO: Rework this shit, it is heinous and deserves to be burned in hell
	if explodeOnImpact:
		for body:Area2D in explosionHurtbox.get_overlapping_areas():
			if body is Hurtbox: explode()

func on_impact(_force:float, _col:KinematicCollision2D, _pre_vel:Vector2):
	explode()

func on_hit(source:Hitbox): ## Called when hitbox registers hit
	if explodeOnHit and !hasExploded: explode()

func explode(): 
	explosionAnimation.play("explode") # this also clears the object after the animation is done
	var hits:Array[Hitbox] = explosionHurtbox.get_overlapping_hitboxes()

	for target:Hitbox in hits:

		if is_instance_valid(target.host): # If target is the hitbox for a host -> run
			var host:HostController = target.host
			if is_instance_valid(host.enemyController):
				var hostBody:ImpulseBody = host.enemyController.impulseBody
				
				var explosionForce:Vector2 = (host.global_position - global_position).normalized() * explosionImpulse
				hostBody.give_impulse(explosionForce)
		target.hurt(explosionDamage)
