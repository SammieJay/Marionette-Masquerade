extends Node2D

func _ready() -> void:
	$HBoxContainer/start_btn.pressed.connect(_on_start_button_pressed)
	$HBoxContainer/level_select_btn.pressed.connect(_on_level_select_button_pressed)

func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/tutorial.tscn")
	
func _on_level_select_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/level_select.tscn")
