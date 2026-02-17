class_name pistol_projectile
extends Area2D

var damage: int
var direction: Vector2 
var speed = 2200.0 
var source:Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)
	pass 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	position += direction * speed * delta

func _on_body_entered(body):
	if source!=null and body!=source:
		queue_free()
	if body is Host:
		body.die()
