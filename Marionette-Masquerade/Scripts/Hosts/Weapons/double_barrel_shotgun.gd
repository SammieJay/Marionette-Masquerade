## [DoubleBarrelShotgun] – A basic 2 shot shotgun with high spread
class_name DoubleBarrelShotgun extends Weapon

var totalSpreadDeg:float = 20.0
var numPellets:int = 5

func _ready(): 
	super._ready() ## Call ready function of parent class for mandatory class setup
	maxAmmo = 2
	reloadTime = 2.0
	damage = 0.34
	projectileSpeed = 1.75
	fire_rate = 0.3
	

## Override of the fire_shot function, just summons a projectile and passes the relevent information throught the instance_projectile function
func fire_shot(_dir:Vector2)->void:
	var currentDeg:float = totalSpreadDeg/2
	var degPerPellet:float = totalSpreadDeg/numPellets
	for i in numPellets:
		instance_projectile(_dir.rotated(deg_to_rad(currentDeg)), projectileSpeed, damage)
		currentDeg -= degPerPellet
	ammo-=1
		
