class_name SpaceObjectKinematic extends CharacterBody2D

enum ORBIT_BEHAVIOR {PULL, PUSH, KEEP_IN, AVOID}
enum MOVEMENT_STATE {FOLLOWING_ORBITS, IGNORE_ORBITS, IGNORE_ORBITS_KEEP_VELOCITY}
const TIMEIGNORING : float = 3.0
var ignoretime_left : float = 0.0

var currMovementState : MOVEMENT_STATE = MOVEMENT_STATE.FOLLOWING_ORBITS

var targetVelocity : Vector2 = Vector2.ZERO
var orbits = []

var awayFromCenter : float = 0.25 #default is for KEEP_IN
var awayFromCenter_keepin : float = 0.25
var awayFromCenter_pullin : float = 0.9
var awayFromCenter_avoid : float = 0.9

var avoidanceProgress : float = 0.0
var attachedWithRotation : bool = false
var avoidanceStartVel : Vector2 = Vector2.ZERO

var speed : float = 65
var global_speed_scale : float = 0.15
var useSmoothVelocity : bool = false

var physics_paused: bool = false
var paused_last_pos : Vector2 = Vector2.ZERO

func _get_curr_orbit():
	return orbits[orbits.size()-1]

func _set_curr_movement_state(newMS : MOVEMENT_STATE):
	currMovementState = newMS
	if newMS == MOVEMENT_STATE.IGNORE_ORBITS or newMS == MOVEMENT_STATE.IGNORE_ORBITS_KEEP_VELOCITY:
		ignoretime_left = TIMEIGNORING

func _get_body_radius() -> float:
	return ($HitCollision.shape as CircleShape2D).radius

func set_away_value_keep_in(newVal):
	awayFromCenter_keepin = clampf(newVal, 0, 1)

func set_away_value(newVal):
	awayFromCenter = clampf(newVal, 0, 1)

func on_orbit_behavior_changed(in_orbit):
	if _get_curr_orbit() == in_orbit:
		_reinitialize_away_factor()

func _reinitialize_away_factor():
	var curr_orbit_behavior
	if _get_curr_orbit().has_method("get_orbit_behavior"):
			curr_orbit_behavior = _get_curr_orbit().get_orbit_behavior()
	else:
		printerr("space-object.gd: referencing an outdated Orbit2D function get_orbit_behavior()")
		set_process(false)
		return
	if curr_orbit_behavior == ORBIT_BEHAVIOR.KEEP_IN:
		awayFromCenter = awayFromCenter_keepin
	elif curr_orbit_behavior == ORBIT_BEHAVIOR.PULL:
		awayFromCenter = awayFromCenter_pullin
	elif curr_orbit_behavior == ORBIT_BEHAVIOR.AVOID:
		avoidanceProgress = 0.0
		avoidanceStartVel = targetVelocity
		
		var rotationParent = _get_curr_orbit().get_parent().get_node("black_hole_rotation")
		if rotationParent != null:
			reparent(rotationParent)
		else:
			reparent(_get_curr_orbit(), true)
			printerr("planet eneterd in avoidance mode but couldn't find the rotation parent")
		
		awayFromCenter = awayFromCenter_avoid
	

func _on_entered_orbit(body):
	
	if body.is_in_group("orbits"):
		orbits.push_back(body)
		
		_reinitialize_away_factor()

func _draw():
	return
	if orbits.size() > 0:
		draw_circle(_get_curr_orbit().position - position, 24, Color.RED)
		
		var pastTargetPoint : bool = (_get_curr_orbit().position + (_get_curr_orbit().position.direction_to(position) * _get_curr_orbit().get_orbit_radius() * awayFromCenter)).distance_to(_get_curr_orbit().position) < position.distance_to(_get_curr_orbit().position)
		var col = Color.DEEP_PINK if pastTargetPoint else Color.GREEN
		
		draw_circle(_get_curr_orbit().position + (_get_curr_orbit().position.direction_to(position) * _get_curr_orbit().get_orbit_radius() * awayFromCenter) - position, 16, col)
		
		var sidePushOffset = _get_curr_orbit().position.direction_to(position).orthogonal()
		draw_circle(_get_curr_orbit().position + (_get_curr_orbit().position.direction_to(position) * _get_curr_orbit().get_orbit_radius() * awayFromCenter) + sidePushOffset - position, 16, Color.YELLOW)

func keep_body_in(orbit_pos, orbit_radius, delta):
	var targetPoint = orbit_pos + (orbit_pos.direction_to(position) * orbit_radius * awayFromCenter)
	speed = remap(orbit_radius, 800, 2000, 1, 20) * global_speed_scale
	if useSmoothVelocity:
		var interpSpeed = remap(orbit_radius, 800, 2000, 0.1, 0.5)
		targetVelocity = targetVelocity + ((targetPoint - position + orbit_pos.direction_to(position).orthogonal() * speed) - targetVelocity) * (delta * interpSpeed)
	else:
		targetVelocity = (targetPoint - position + orbit_pos.direction_to(position).orthogonal() * speed)
	move_and_collide(targetVelocity)

func body_avoid(orbit_pos, orbit_radius, delta):
	targetVelocity.x = targetVelocity.x + (0 - targetVelocity.x) * (delta * 8)
	targetVelocity.y = targetVelocity.y + (0 - targetVelocity.y) * (delta * 8)
	move_and_collide(targetVelocity)

func _physics_process(delta):
	
	if physics_paused:
		position = paused_last_pos
		return
	
	if currMovementState == MOVEMENT_STATE.IGNORE_ORBITS:
		ignoretime_left -= delta
		if ignoretime_left <= 0:
			_set_curr_movement_state(MOVEMENT_STATE.FOLLOWING_ORBITS)
		else:
			return
	elif currMovementState == MOVEMENT_STATE.IGNORE_ORBITS_KEEP_VELOCITY:
		targetVelocity.x = targetVelocity.x + (0 - targetVelocity.x) * (delta * 3)
		targetVelocity.y = targetVelocity.y + (0 - targetVelocity.y) * (delta * 3)
		move_and_collide(targetVelocity)
		
		ignoretime_left -= delta
		if ignoretime_left <= 0:
			_set_curr_movement_state(MOVEMENT_STATE.FOLLOWING_ORBITS)
	
	if orbits.size() > 0:
		var curr_orbit_radius : float = 0
		var curr_orbit_behavior : ORBIT_BEHAVIOR = ORBIT_BEHAVIOR.KEEP_IN
		
		#sanity checks
		var curr_orbit : Node2D = _get_curr_orbit()
		
		if curr_orbit.has_method("get_orbit_radius"):
			curr_orbit_radius = curr_orbit.get_orbit_radius()
		else:
			printerr("space-object.gd: referencing an outdated Orbit2D function get_orbit_radius()")
			set_process(false)
		
		if curr_orbit.has_method("get_orbit_behavior"):
			curr_orbit_behavior = curr_orbit.get_orbit_behavior()
		else:
			printerr("space-object.gd: referencing an outdated Orbit2D function get_orbit_behavior()")
			set_process(false)
		
		if curr_orbit_behavior == ORBIT_BEHAVIOR.KEEP_IN:
			keep_body_in(curr_orbit.position, curr_orbit_radius, delta)
		elif curr_orbit_behavior == ORBIT_BEHAVIOR.PULL:
			awayFromCenter = awayFromCenter + (0 - awayFromCenter) * (delta * 0.8)
			keep_body_in(curr_orbit.position, curr_orbit_radius, delta)
		elif curr_orbit_behavior == ORBIT_BEHAVIOR.AVOID:
			targetVelocity.x = targetVelocity.x + (0 - targetVelocity.x) * (delta * 7)
			targetVelocity.y = targetVelocity.y + (0 - targetVelocity.y) * (delta * 7)
			avoidanceProgress = avoidanceProgress + (1 - avoidanceProgress) * (delta * 1.0)
			move_and_collide(targetVelocity)
			
			if avoidanceProgress > 0.92:
				targetVelocity = avoidanceStartVel.orthogonal() * 1.34
				_set_curr_movement_state(MOVEMENT_STATE.IGNORE_ORBITS_KEEP_VELOCITY)
	else:
		move_and_collide(Vector2.DOWN * 9.8)

func pause_requested():
	physics_paused = true
	paused_last_pos = position

func unapause():
	physics_paused = false
