## ResourcePlayer – Overrides Throwing Player to add resource mechanic over top
class_name ResourcePlayer extends ThrowingPlayer

@export var resourceTracker:HostResourceManager

var grabCost:float
var throwCost:float

func _ready():
	super._ready() ## Parent ready call
	assert(resourceTracker, "Host has no given resource tracker")

	grabCost = resourceTracker.resourceManager.grabCost
	throwCost = resourceTracker.resourceManager.throwCost


func on_possession()->void:
	print("Test")
	resourceTracker.updateManager()
	super.on_possession()

func on_possession_release()->void:
	super.on_possession_release()


## ===== GRAPPLE AND THROW FUNCTIONS ===== ##

## Start grab on given enemy
func grab_enemy(_host:HostController)->void:
	if resourceTracker.has_resource(grabCost):
		super.grab_enemy(_host)
		resourceTracker.spend_resource(grabCost)
	


func shove_enemy(_dir:Vector2):
	if resourceTracker.has_resource(throwCost):
		super.shove_enemy(_dir)
		resourceTracker.spend_resource(throwCost)
