class_name HealthBar extends TextureProgressBar

@export var test_visible:bool = true

@export var host:HostController ## Mandatory reference to the host this healthbar belongs to

##AUSTIN TODO
@export var hideOnPlayerPosession:bool = false ## Hide this healthbar when posessed by player 

@export var updateBuffer:float = 0.1 ## How often this healthbar updates itself in seconds

var updateTimer:float

# Called when the node enters the scene tree for the first time.
func _ready():
	updateTimer = updateBuffer
	assert(host, "Healthbar requires reference to it's host via Export Variable")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	updateTimer -= delta
	
	## Update health value every buffer frame
	if updateTimer <= 0.0:
		updateTimer = updateBuffer
		update_healthbar_value()
	
	## Center Health Bar above Host
	global_position = host.global_position + Vector2(-size.x/4.0, -30)

## Update the value of the healthbar to the proportional value of the host's health
func update_healthbar_value():
	var displayHealth = host.currentHealth + host.tempHealth
	var displayMaxHealth = host.MAX_HEALTH + host.tempMaxHealth
	
	if displayHealth <= 0:
		#if host.is_possessed(): print("1")
		value = 0.0
		visible = false
	elif displayHealth == displayMaxHealth:
		#if host.is_possessed(): print("2")
		visible = false
	else:
		visible = true
		value = displayHealth / displayMaxHealth
