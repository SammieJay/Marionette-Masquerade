## [Prop] – Root node for interactable and movable objects like barrels and crates
##
## [b]Responsibilities:[/b] [br]
##   - Handle logic for object health and on collision logic for non-host objects [br]
class_name Prop extends CharacterBody2D

@export var body:ImpulseBody ## The impulse body for this object

@export_group("Explosion Settings")
@export var explodeOnImpact:bool = false
@export var explosionHurtbox:Hurtbox
#@export var explosionImpulse:float = 5.0
@export var explosionAnimation:AnimationPlayer

func _ready():
	body.impact.connect(on_impact)



func on_impact(_force:float, _col:KinematicCollision2D, _pre_vel:Vector2):
	explode()

func explode(): explosionAnimation.play("explode")
