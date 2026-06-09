## [HostEffectHandler] – handles effects and animations like activating weapon and switching hosts
##
## [b]Responsibilities:[/b] [br]
##   - Store paths of REQUIRED effects like shooting and host switching [br]
##   - Play any other effects when prompted by other classes [br]
class_name HostEffectHandler extends AnimationPlayer

@export_category("Required Effect Paths")
@export var switchHostEffectName:String = "UNNAMED EFFECT"
@export var switchHostMissEffectName:String = "UNNAMED EFFECT"
@export var stunEffectName:String = "UNNAMED EFFECT"
@export var shootEffectName:String = "UNNAMED EFFECT"
@export var deathEffectName:String = "UNNAMED EFFECT"

@export_category("Stun Effect")
@export var stunSprite:AnimatedSprite2D
@export var stunSpriteRotationSpeed:float = 100.0

@export_category("DEBUG")
@export var doDebugPrints:bool = false
@export var requireDefaultEffects:bool = false


## ===== SCRIPT VARIABLES =====

var host:HostController

var stunActive:bool = false


## ===== CORE FUNCTIONS =====

# Called when the node enters the scene tree for the first time.
func _ready():
	if requireDefaultEffects:
		assert(switchHostEffectName != null, "HostEffectHandler for %s has no SwitchHost effect path" % host.hostTypeName)
		assert(switchHostMissEffectName != null, "HostEffectHandler for %s has no SwitchHostMiss effect path" % host.hostTypeName)
		assert(stunEffectName != null, "HostEffectHandler for %s has no Stun effect path" % host.hostTypeName)
		assert(shootEffectName != null, "HostEffectHandler for %s has no SwitchHost effect path" % host.hostTypeName)
		assert(deathEffectName != null, "HostEffectHandler for %s has no Death effect path" % host.hostTypeName)

		assert(stunSprite, "HostEffectHandler for %s has no stun sprite" % host.hostTypeName)


# Mostly for updating stun effect sprite
func _process(_delta):
	if stunActive and stunSprite:
		if !stunSprite.visible: stunSprite.visible = true # show sprite if hidden
		stunSprite.rotation_degrees += stunSpriteRotationSpeed * _delta
	elif stunSprite and stunSprite.visible: stunSprite.visible = false # hide sprite if shown and stun)active

## Start or continue playing effect of given name, if doDebugPrints is enabled and effect not found, will print error to console [br]
## [b]Expects:[/b] The given animation name to exist within the animation player [br]
func update_effect(_name:String):
	if has_animation(_name):
		queue(_name)
	elif doDebugPrints: printerr("Animation Not Found In %s: %s" %[host.hostTypeName, _name])


## ===== Mandatory Effect Functions =====
# Functions that activate effects 
func play_switch_effect(_hit:bool):
	if _hit: update_effect(switchHostEffectName)
	else: update_effect(switchHostMissEffectName)

func play_death_effect(): update_effect(deathEffectName)
func play_shoot_effect(): update_effect(shootEffectName)
func play_stun_effect(): update_effect(stunEffectName)

# Stun effect setter
func set_stun(_active:bool): stunActive = _active ## Set whether the stun sprite should be active or not





