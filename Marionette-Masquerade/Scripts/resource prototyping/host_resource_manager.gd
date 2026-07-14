class_name HostResourceManager extends Node

var resource:float = 1.0

var resourceManager:ResourceManager

func _ready():
	resourceManager = get_tree().get_first_node_in_group("ResourceManager")
	if !resourceManager: printerr("HostResourceManager could not find global ResourceManager from group")

func has_resource(_val:float)->bool:
	var value := clampf(_val, 0.0, 1.0)
	
	if resource >= value: return true
	else: return false

## Returns true if resource is high enough to spend, otherwise returns false
func spend_resource(_val:float):
	var value := clampf(_val, 0.0, 1.0)
	if has_resource(value):
		resource -= value
		print("Resource is now: ", resource)
		updateManager()

func reset_resource(): 
	resource = 1.0
	updateManager()

func updateManager():
	resourceManager.setCurrentResource(resource)