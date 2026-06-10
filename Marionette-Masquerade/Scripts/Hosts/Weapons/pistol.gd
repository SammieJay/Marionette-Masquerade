## [Pistol] – a basic pistol override of the Weapon class
class_name Pistol extends Weapon

func _ready(): 
	super._ready() ## Call ready function of parent class for mandatory class setup
	maxAmmo = 12
	reloadTime = 2.0
	damage = 1.0
	projectileSpeed = 1.75
	fire_rate = 0.25
	

## Override of the fire_shot function, just summons a projectile and passes the relevent information throught the instance_projectile function
func fire_shot(_dir:Vector2)->void:
	instance_projectile(_dir, projectileSpeed, damage)
