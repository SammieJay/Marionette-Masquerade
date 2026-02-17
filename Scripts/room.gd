extends Node

@export var hosts:Array[Host]

@onready var door := $Door


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if isRoomCleared():
		door.open()

func isRoomCleared() -> bool:
	for host in hosts:
		if host.alive and not host.isPlayerControlled:
			return false
	return true
