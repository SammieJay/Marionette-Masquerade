class_name PlayerCamera extends Camera2D

var target: HostController
@onready var hostManager:HostManager

## Editable variables
@export var trackingStrength:float = 2.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hostManager = get_tree().get_first_node_in_group("HostManager")
	if hostManager == null: printerr("camera cannot find Host Manager")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	updateTarget()
	trackTarget(delta)


func trackTarget(delta:float):
	var targetPos: Vector2 = target.global_position
	global_position = global_position.lerp(
		targetPos,
		trackingStrength*delta
	)

func updateTarget():
	if target == hostManager.playerHost: return
	else: 
		var tempTaget = hostManager.playerHost
		if tempTaget: target = tempTaget
