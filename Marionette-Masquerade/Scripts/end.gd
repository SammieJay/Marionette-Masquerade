extends Node2D

func _ready() -> void:
	$menu_btn.pressed.connect(_on_menu_button_pressed)
	

func _on_menu_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/title_screen.tscn")
