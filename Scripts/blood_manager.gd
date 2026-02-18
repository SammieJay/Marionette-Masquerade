extends Node2D
	
@export var bloodScene: PackedScene	
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func spawnBlood(pos: Vector2):
	#print("Blood Spawned")
	var blood = bloodScene.instantiate()
	blood.global_position = pos
	add_child(blood)
