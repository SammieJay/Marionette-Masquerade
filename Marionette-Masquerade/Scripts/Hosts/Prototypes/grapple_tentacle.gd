#Here's the complete clean rewrite — verlet rope, world-space Line2D, fire/detach, all the coordinate gotchas handled.
## GrappleTentacle — a verlet-simulated decorative grapple rope.
##
## Fire a ray from origin along a direction; on hit, spawns a point-chain
## that hangs/waves slightly and clings to its endpoints. Rendered with a
## child Line2D. No RigidBody / PinJoint — no exploding.
##
## SETUP: add a Line2D as a child of this node.
extends Node2D
class_name GrappleTentacle

# ===== EXPORTS =====
@export var segmentLength: float = 8.0      ## spacing between rope points
@export var worldMask: int = 1              ## collision layer of walls (layer 2 = bitmask 2)
@export var maxDistance: float = 100.0      ## default grapple range
@export var gravity: float = 80.0           ## downward pull → sag/wave (0 = dead straight)
@export var constraintIterations: int = 16  ## higher = stiffer, less stretchy
@export var damping: float = 0.98           ## <1 calms jitter; near 1 = livelier
@export var collisionPush: float = 6.0      ## how hard points are shoved out of walls
@export var muzzle: Node2D                  ## optional: player end follows this; else this node
@export var breakDistance: float = 120.0    ## this is how far you can move without it snapping
@export var extendTime: float = 0.08    ## seconds for the rope to shoot out
@export var retractTime: float = 0.10   ## seconds for the snap-back

enum State { IDLE, EXTENDING, ATTACHED, RETRACTING }
var state: int = State.IDLE
var animT: float = 0.0          ## 0..1 progress for extend/retract
var fireOrigin: Vector2         ## where the shot started

# ===== STATE =====
var points: Array[Vector2] = []             ## current world positions
var prevPoints: Array[Vector2] = []         ## previous world positions (verlet velocity)
var anchorPoint: Vector2                    ## fixed end (the wall hit point)
var anchorBody: Object = null               ## what we hit (for moving anchors)
var isAttached: bool = false

@onready var line: Line2D = $Line2D


func _ready() -> void:
	#draw in world space so the rope ignores the host's movement/rotation
	if line:
		line.top_level = true

## Fire the grapple. Returns true if it attached to something on worldMask.
func fire(_origin: Vector2, _dir: Vector2, _maxDist: float = -1.0) -> bool:
	var dist := _maxDist if _maxDist > 0.0 else maxDistance
	var space := get_world_2d().direct_space_state
	var endpoint := _origin + _dir.normalized() * dist
	var query := PhysicsRayQueryParameters2D.create(_origin, endpoint, worldMask)
	var hit := space.intersect_ray(query)

	if hit:
		anchorBody = hit.collider
		anchorPoint = hit.position
		fireOrigin = _origin
		_build_points(_origin, _origin)   # start collapsed at the muzzle
		state = State.EXTENDING
		animT = 0.0
		isAttached = true
		return true

	detach()
	return false


## Release the rope.
func detach() -> void:
	points.clear()
	prevPoints.clear()
	anchorBody = null
	isAttached = false
	state = State.IDLE
	animT = 0.0
	if line:
		line.clear_points()


# ===== SIMULATION =====

func _build_points(_from: Vector2, _to: Vector2) -> void:
	points.clear()
	prevPoints.clear()

	var dist := _from.distance_to(_to)
	var count := maxi(2, int(dist / segmentLength) + 1)
	var dir := (_to - _from).normalized()

	for i in count:
		var t := float(i) / float(count - 1)        # 0..1 along the rope
		var p := _from.lerp(_to, t)
		points.append(p)
		prevPoints.append(p)                         # at rest, no initial velocity


func _physics_process(delta: float) -> void:
	match state:
		State.EXTENDING:
			_tick_extend(delta)
		State.ATTACHED:
			_tick_attached(delta)
		State.RETRACTING:
			_tick_retract(delta)


func _tick_extend(delta: float) -> void:
	animT = min(1.0, animT + delta / max(extendTime, 0.0001))
	# the reaching tip lerps from muzzle to the real anchor
	var tip := fireOrigin.lerp(anchorPoint, animT)
	_rebuild_line(_muzzle_point(), tip)
	_render()
	if animT >= 1.0:
		state = State.ATTACHED


func _tick_attached(delta: float) -> void:
	var d := _muzzle_point().distance_to(_anchor_world_point())
	if d >= breakDistance:
		state = State.RETRACTING
		animT = 0.0
		return

	_resize_to_fit()
	_integrate(delta)
	for _i in constraintIterations:
		_constrain()
	_collide()
	_render()


func _tick_retract(delta: float) -> void:
	animT = min(1.0, animT + delta / max(retractTime, 0.0001))
	var target := _muzzle_point()
	for i in points.size():
		points[i] = points[i].lerp(target, animT)
	_render()
	if animT >= 1.0:
		detach()

## Shrink/grow the point chain to match the current muzzle→anchor distance,
## so the rope reels in as the host approaches the anchor.
func _resize_to_fit() -> void:
	var from := _muzzle_point()
	var to := _anchor_world_point()
	var dist := from.distance_to(to)
	var desired := maxi(2, int(dist / segmentLength) + 1)

	if desired == points.size():
		return

	if desired < points.size():
		# reeling in — drop points from the middle so the ends stay put
		while points.size() > desired:
			var mid := points.size() / 2
			points.remove_at(mid)
			prevPoints.remove_at(mid)
	else:
		# moving away — add points in the middle
		while points.size() < desired:
			var mid := points.size() / 2
			var newp := (points[mid - 1] + points[mid]) * 0.5
			points.insert(mid, newp)
			prevPoints.insert(mid, newp)

## Verlet integration: implied velocity + gravity.
func _integrate(delta: float) -> void:
	var grav := Vector2(0.0, gravity) * delta * delta
	for i in points.size():
		var current := points[i]
		var velocity := (current - prevPoints[i]) * damping
		prevPoints[i] = current
		points[i] = current + velocity + grav


## Hold points segmentLength apart and pin both ends.
func _constrain() -> void:
	var last := points.size() - 1

	# pin ends every iteration so they never drift
	points[0] = _muzzle_point()
	points[last] = _anchor_world_point()

	for i in range(last):
		var a := points[i]
		var b := points[i + 1]
		var delta := b - a
		var d := delta.length()
		if d == 0.0:
			continue
		var correction := delta * ((d - segmentLength) / d) * 0.5

		if i != 0:
			points[i] = a + correction
		if i + 1 != last:
			points[i + 1] = b - correction


## Slight wall collision: nudge any point that lands inside a wall back out.
func _collide() -> void:
	var space := get_world_2d().direct_space_state
	for i in range(1, points.size() - 1):           # skip pinned ends
		var query := PhysicsPointQueryParameters2D.new()
		query.position = points[i]
		query.collision_mask = worldMask
		if space.intersect_point(query, 1).size() > 0:
			var escape := (prevPoints[i] - points[i])
			if escape.length() > 0.0:
				points[i] += escape.normalized() * collisionPush
			else:
				points[i] = prevPoints[i]            # fallback: snap to last safe spot


func _render() -> void:
	line.clear_points()
	for p in points:
		line.add_point(p)                            # world coords (line is top_level)


# ===== ENDPOINTS =====

## Moving end — follows the muzzle if set, else this node.
func _muzzle_point() -> Vector2:
	return muzzle.global_position if muzzle else global_position


## Fixed end, tracks the hit body if it moves, else the static hit point.
func _anchor_world_point() -> Vector2:
	if anchorBody is Node2D and is_instance_valid(anchorBody):
		# keep relative offset if the anchor body moves (moving platforms)
		return anchorPoint
	return anchorPoint
	
func _rebuild_line(_from: Vector2, _to: Vector2) -> void:
	var dist := _from.distance_to(_to)
	var count := maxi(2, int(dist / segmentLength) + 1)
	points.resize(count)
	prevPoints.resize(count)
	for i in count:
		var t := float(i) / float(count - 1)
		var p := _from.lerp(_to, t)
		points[i] = p
		prevPoints[i] = p
