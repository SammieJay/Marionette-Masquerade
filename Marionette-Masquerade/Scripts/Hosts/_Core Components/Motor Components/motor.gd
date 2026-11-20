## [Motor] – An abstract class that contains the foundation for controlling the physics of a body, whether that's a host, thowable, rolling boulder, you name it
##
## [b]Responsibilities:[/b] [br]
##   - Contains a reference to a Characterbody2D
##	 - Contains functions that are called by the parent body of this motor to update the character body's transform
class_name Motor extends Node

@export var body:CharacterBody2D;

## [ABSTRACT][br]
##Handles startup process for Motors[br]
## Call this when motor becomes active
func enter(): pass

## [ABSTRACT] [br]
## Call this when motor is no longer active (on exit)
func exit(): pass

## [ABSTRACT][br]
## Return desired velocity. the entity must apply it manually
func compute_velocity(_delta:float) -> Vector2: return Vector2.ZERO

## [ABSTRACT][br]
## Return desired global rotation in radians. the entity must apply it manually
func compute_rotation(_delta:float) -> float: return body.global_rotation