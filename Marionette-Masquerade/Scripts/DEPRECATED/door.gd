extends Node2D

@onready var doorBlocker := $DoorCol/CollisionShape2D
@onready var doorsprite = $Sprite2D
#@onready var area := $Area2D

var locked = true
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	doorsprite.play()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func isLocked() -> bool:
	return locked
	
func open() -> void:
	doorBlocker.disabled = true
	doorsprite.visible = false
	
func close() -> void:
	doorBlocker.disabled = false 
	doorsprite.visible = true
