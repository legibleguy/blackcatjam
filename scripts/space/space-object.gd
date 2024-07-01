class_name SpaceObject extends RigidBody2D

enum ORBIT_BEHAVIOR {PULL, PUSH, KEEP_IN, AVOID}

var orbits = []
var awayFromCenter : float = 0.7

func _get_curr_orbit():
	return orbits[orbits.size()-1]

func _get_body_radius() -> float:
	return ($HitCollision.shape as CircleShape2D).radius

func _on_entered_orbit(body):
	
	if body.is_in_group("orbits"):
#		gravity_scale = 0
		orbits.push_back(body)
		
		var curr_orbit_behavior : ORBIT_BEHAVIOR
		if body.has_method("get_orbit_behavior"):
			curr_orbit_behavior = body.get_orbit_behavior()
		else:
			printerr("space-object.gd: referencing an outdated Orbit2D function get_orbit_behavior()")
			set_process(false)
			return
#		if curr_orbit_behavior == ORBIT_BEHAVIOR.PULL:
#			awayFromCenter = 1.0 #the behavior of PULL is to start at max distance 1 and interpolate to 0 
		
		#debug
		var id : float = 50 * (orbits[orbits.size()-1].get_index() as float) / (orbits[orbits.size()-1].get_parent().get_child_count() as float)
		$Sprite.modulate = Color(id, id, id)

func _on_exit_orbit(body):
	queue_redraw()
	if body.is_in_group("orbits") and body in orbits:
		orbits.erase(body)
		
		#debug
		if orbits.size() > 0:
			var id : float = 50 * (orbits[orbits.size()-1].get_index() as float) / (orbits[orbits.size()-1].get_parent().get_child_count() as float)
			$Sprite.modulate = Color(id, id, id)
		else:
			$Sprite.modulate = Color(0,0,0)

func _draw():
	if orbits.size() > 0:
		draw_circle(_get_curr_orbit().position - position, 24, Color.RED)
		$ReadyToBeSucked.play()
		var pastTargetPoint : bool = (_get_curr_orbit().position + (_get_curr_orbit().position.direction_to(position) * _get_curr_orbit().get_orbit_radius() * awayFromCenter)).distance_to(_get_curr_orbit().position) < position.distance_to(_get_curr_orbit().position)
		var col = Color.DEEP_PINK if pastTargetPoint else Color.GREEN
		
		draw_circle(_get_curr_orbit().position + (_get_curr_orbit().position.direction_to(position) * _get_curr_orbit().get_orbit_radius() * awayFromCenter) - position, 16, col)
		
		var sidePushOffset = _get_curr_orbit().position.direction_to(position).orthogonal()
		draw_circle(_get_curr_orbit().position + (_get_curr_orbit().position.direction_to(position) * _get_curr_orbit().get_orbit_radius() * awayFromCenter) + sidePushOffset - position, 16, Color.YELLOW)

# Called when the node enters the scene tree for the first time.
func _ready():
	var ran = randf_range(0.5, 1)
	await get_tree().create_timer(ran).timeout
	mass *= ran
	

func push_body_along(orbit_pos, orbit_radius):
	var body_radius = _get_body_radius()
	var alpha : float = orbit_pos.distance_to(position) / orbit_radius
	var force : float =  lerp(10500, 2150, alpha) * (1 / mass)
	var orbitToBody = orbit_pos.direction_to(position).orthogonal() * force
	apply_central_force(orbitToBody)

func stupid_test(orbit_pos, orbit_radius):
	var target_point : Vector2 = (orbit_pos.direction_to(position) * orbit_radius * awayFromCenter)
	var pastTargetPoint : bool = target_point.distance_to(orbit_pos) < position.distance_to(orbit_pos)
	var movingAlpha : float = clampf(linear_velocity.length() / orbit_radius, 0, 1)
	
	if pastTargetPoint:
		var moveToOrbitEdgeAplha : float = clampf(linear_velocity.normalized().dot(orbit_pos.direction_to(position)), 0, 1) * movingAlpha
		var targetToEdge : Vector2 = (orbit_pos.direction_to(position) * orbit_radius) - (orbit_pos.direction_to(position) * orbit_radius * awayFromCenter)
		var selfToTarget : Vector2 = position - (target_point + orbit_pos)
		var targetToOrbitEdgeAlpha : float = selfToTarget.length() / (targetToEdge.length()/2)
		
		#emergency braking that ensures the space object stays within its orbit
		apply_force(-2 * linear_velocity * moveToOrbitEdgeAplha * targetToOrbitEdgeAlpha)
		var actual_force : Vector2 = (orbit_pos - target_point) - position
		apply_force(actual_force * 5)
	else:
		var actual_force : Vector2 = position.direction_to(orbit_pos + target_point) * linear_velocity.length()
		apply_force(actual_force * 2)
	
	var selfToTarget : Vector2 = position - (target_point + orbit_pos)
#	apply_force(orbit_pos.direction_to(position).orthogonal()/ 10)

func gravity_override(orbit_pos, orbit_radius):
	pass

func keep_body_in(orbit_pos, orbit_radius):
	var moveToOrbitEdgeAplha : float = linear_velocity.dot(orbit_pos.direction_to(position))
	var target : Vector2 = orbit_pos + (orbit_pos.direction_to(position) * (orbit_radius * awayFromCenter))
	var forceToTarget = (target - position) * mass
	var forceToKeepIn = linear_velocity * clampf(moveToOrbitEdgeAplha, 0 ,1)
	var force_total = forceToTarget - forceToKeepIn
	apply_force(force_total)
	
	$ForceDirection.rotation = rad_to_deg(force_total.angle())

func pull_body_in(orbit_pos, orbit_radius):
	var velocity_alpha : float = clampf(linear_velocity.length() / (orbit_radius/2), 0.0, 1.0)
	var velocity_negate : Vector2 = linear_velocity.length() * -1.34 * position.direction_to(orbit_pos) * velocity_alpha
	
	var targetPoint = (orbit_pos.direction_to(position) * (orbit_radius/2)) + orbit_pos
	var force = position.direction_to(targetPoint) * position.distance_to(targetPoint)
	apply_central_force(force - velocity_negate)
	
	if velocity_alpha < 0.45:
		push_body_along(orbit_pos, orbit_radius)

func _physics_process(delta):
	queue_redraw()
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
		
#		stupid_test(curr_orbit.position, curr_orbit_radius)
		return
		
#		if curr_orbit_behavior == ORBIT_BEHAVIOR.KEEP_IN:
#			keep_body_in(curr_orbit.position, curr_orbit_radius)
#		elif curr_orbit_behavior == ORBIT_BEHAVIOR.PULL:
#			awayFromCenter = awayFromCenter + (0 - awayFromCenter) * (delta * 0.8)
#			keep_body_in(curr_orbit.position, curr_orbit_radius)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
