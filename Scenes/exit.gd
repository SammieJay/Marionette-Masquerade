extends Area2D

@export var nextScene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	print(body.name)
	if nextScene == null:
		print("No scene assigned")
		return
	print(str(body.name) + " entered exit, changing scene")
	print(body)
	if (body is Host):
		if body.isPlayerControlled == true:
			TransistionScreen.transition()
			await TransistionScreen.transitionFinished
#			Waits till the end of a physics process to swap 
			call_deferred("_deferred_change_scene")
	
func _deferred_change_scene():
	get_tree().change_scene_to_packed(nextScene)
