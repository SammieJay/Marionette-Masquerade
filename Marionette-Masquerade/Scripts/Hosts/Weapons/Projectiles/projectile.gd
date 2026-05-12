class_name Projectile extends Area2D

var damage:float
var direction:Vector2
var speed:float
var host:HostController

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)
	pass 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	global_position += direction * speed * delta

func _on_body_entered(body):
	if body is HostController and body != host:
		print("HIT DETECTED WITH %s" % host.name)
	if body!=host:
		queue_free()
	