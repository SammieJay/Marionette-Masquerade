extends Node

## PHYSICS LAYERS

const LEVEL_PHYSICS_LAYER:= 1 ## This layer contains all static and solid level objects
const HOST_PHYSICS_LAYER := 2 ## This layer contains all colliders for hosts and entities - FOR PHYSICS COLLISIONS ONLY NOT HIT DETECTION
const HAZARD_PHYSICS_LAYER := 3 ## This layer contains all Hazardous objects like projectiles, stage hazards, and other hurtboxes
const HITBOX_PHYSICS_LAYER := 4 ## This layer contains all damage receiving hitboxes for entities


## MOVEMENT

const MOVE_SPEED_CONST:float = 1200.0

## CONTROLS

const MOUSE_SENSITIVITY:float = 0.25
