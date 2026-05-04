extends Node2D

func _ready() -> void:
	$HBoxContainer/one.pressed.connect(_on_one_button_pressed)
	$HBoxContainer/two.pressed.connect(_on_two_button_pressed)
	$HBoxContainer/three.pressed.connect(_on_three_button_pressed)
	$back.pressed.connect(_on_back_button_pressed)
func _on_one_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/intro.tscn")
	
func _on_two_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/level_two.tscn")
	
func _on_three_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/level_three.tscn")

func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/title_screen.tscn")
