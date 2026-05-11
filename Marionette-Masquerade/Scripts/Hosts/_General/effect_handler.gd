## [EffectHandler] – handles effects and animations like activating weapon and switching hosts
##
## [b]Responsibilities:[/b] [br]
##   - Store paths of REQUIRED effects like shooting and host switching [br]
##   - Play any other effects when prompted by other classes [br]
class_name HostEffectHandler extends AnimationPlayer

@export_category("Required Effect Paths")
@export var switchHostEffectName:String = "UNSPECIFIED EFFECT NAME"
@export var switchHostMissEffectName:String = "UNSPECIFIED EFFECT NAME"
@export var stunEffectName:String = "UNSPECIFIED EFFECT NAME"
@export var shootEffectName:String = "UNSPECIFIED EFFECT NAME"

@export_category("DEBUG")
@export var doDebugPrints:bool = false
@export var requireDefaultEffects:bool = false


## ===== SCRIPT VARIABLES =====

var host:HostController


## ===== CORE FUNCTIONS =====

# Called when the node enters the scene tree for the first time.
func _ready():
	if requireDefaultEffects:
		assert(switchHostEffectName != null, "HostEffectHandler for %s has no SwitchHost effect path" % host.hostTypeName)
		assert(stunEffectName != null, "HostEffectHandler for %s has no Stun effect path" % host.hostTypeName)
		assert(shootEffectName != null, "HostEffectHandler for %s has no SwitchHost effect path" % host.hostTypeName)


## Start or continue playing effect of given name, if doDebugPrints is enabled and effect not found, will print error to console [br]
## [b]Expects:[/b] The given animation name to exist within the animation player [br]
func update_effect(_name:String):
	if has_animation(_name):
		play(_name)
	elif doDebugPrints: printerr("Animation Not Found In %s: %s" %[host.hostTypeName, _name])
	


## ===== Mandatory Effect Functions =====

func play_switch_effect(_hit:bool): 
	if _hit: update_effect(switchHostEffectName)
	else: update_effect(switchHostMissEffectName)


func play_shoot_effect(): update_effect(shootEffectName)
func play_stun_effect(): update_effect(stunEffectName)




