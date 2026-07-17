class_name ResourceManager extends Node

@export var grabCost:float = 0.25
@export var throwCost:float = 0.25

@export var resourceDisplay:ProgressBar

var resource:float = 1.0

func _ready():
	if !resourceDisplay: printerr("Resource Manager Has No Reference To Display")


func setCurrentResource(_val:float): 
	resource = _val

func clamp_resource():
	resource = clampf(resource, 0.0, 1.0)

func reset_resource(): resource = 1.0

func _process(_delta:float):
	clamp_resource()
	if resourceDisplay: 
		update_resource_display()

func update_resource_display():
	if resourceDisplay.value != resource: print("Setting bar to: ", resource)
	resourceDisplay.value = resource

