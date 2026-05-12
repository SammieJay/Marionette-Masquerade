extends Node2D

func _process(delta: float) -> void:
	var tree := get_tree()

	await tree.create_timer(1.5).timeout
	$ColorRect.hide()

	await tree.create_timer(1.5).timeout
	$ColorRect2.hide()

	await tree.create_timer(1.5).timeout
	$ColorRect3.hide()
	
	await tree.create_timer(1.5).timeout

	tree.change_scene_to_file("res://Scenes/intro.tscn")
