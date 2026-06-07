class_name Projectile extends Area2D

var damage:float
var direction:Vector2
var speed:float
var host:HostController

var active:bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if active: global_position += direction * speed * delta

func _on_body_entered(body):
	if body == host:return
	if body is HostController and body != host and body.is_alive():
		body.hurt(damage)
		print("HIT DETECTED WITH %s" % body.name)
	
	active = false
	queue_free()
	
