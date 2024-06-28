class_name SpaceObjectKinematic extends CharacterBody2D

enum ORBIT_BEHAVIOR {PULL, PUSH, KEEP_IN, AVOID}

var targetVelocity : Vector2 = Vector2.ZERO
var orbits = []
var awayFromCenter : float = 0.25
var speed : float = 65
var global_speed_scale : float = 0.15
var useSmoothVelocity : bool = false

func _get_curr_orbit():
	return orbits[orbits.size()-1]

func _get_body_radius() -> float:
	return ($HitCollision.shape as CircleShape2D).radius

func set_away_value(newVal):
	awayFromCenter = clampf(newVal, 0, 1)

func _reinitialize_away_factor():
	var curr_orbit_behavior
	if _get_curr_orbit().has_method("get_orbit_behavior"):
			curr_orbit_behavior = _get_curr_orbit().get_orbit_behavior()
	else:
		printerr("space-object.gd: referencing an outdated Orbit2D function get_orbit_behavior()")
		set_process(false)
		return
	if curr_orbit_behavior == ORBIT_BEHAVIOR.KEEP_IN:
		awayFromCenter = clampf(position.distance_to(_get_curr_orbit().position) / _get_curr_orbit().get_orbit_radius(), 0.25, 0.9)
	elif curr_orbit_behavior == ORBIT_BEHAVIOR.PULL:
		awayFromCenter = 0.8
	elif curr_orbit_behavior == ORBIT_BEHAVIOR.AVOID:
		awayFromCenter = 0.99
	

func _on_entered_orbit(body):
	
	if body.is_in_group("orbits"):
		orbits.push_back(body)
		
		var curr_orbit_behavior : ORBIT_BEHAVIOR
		if body.has_method("get_orbit_behavior"):
			curr_orbit_behavior = body.get_orbit_behavior()
		else:
			printerr("space-object.gd: referencing an outdated Orbit2D function get_orbit_behavior()")
			set_process(false)
			return
		if curr_orbit_behavior == ORBIT_BEHAVIOR.KEEP_IN:
			awayFromCenter = clampf(position.distance_to(_get_curr_orbit().position) / _get_curr_orbit().get_orbit_radius(), 0.25, 0.9)
		elif curr_orbit_behavior == ORBIT_BEHAVIOR.PULL:
			awayFromCenter = 0.8
		elif curr_orbit_behavior == ORBIT_BEHAVIOR.AVOID:
			awayFromCenter = 0.99
		
		#debug
		var id : float = 50 * (orbits[orbits.size()-1].get_index() as float) / (orbits[orbits.size()-1].get_parent().get_child_count() as float)
		$Sprite.modulate = Color(id, id, id)

func _on_exit_orbit(body):
	queue_redraw()
	if body.is_in_group("orbits") and body in orbits:
		orbits.erase(body)
		
		#debug
		if orbits.size() > 0:
			
			var curr_orbit_behavior : ORBIT_BEHAVIOR
			if _get_curr_orbit().has_method("get_orbit_behavior"):
				curr_orbit_behavior = _get_curr_orbit().get_orbit_behavior()
			else:
				printerr("space-object.gd: referencing an outdated Orbit2D function get_orbit_behavior()")
				set_process(false)
				return
				
			if curr_orbit_behavior == ORBIT_BEHAVIOR.KEEP_IN:
				awayFromCenter = clampf(position.distance_to(_get_curr_orbit().position) / _get_curr_orbit().get_orbit_radius(), 0.25, 0.9)
			elif curr_orbit_behavior == ORBIT_BEHAVIOR.PULL:
				awayFromCenter = 0.8
			elif curr_orbit_behavior == ORBIT_BEHAVIOR.AVOID:
				awayFromCenter = 0.99
			
			var id : float = 50 * (orbits[orbits.size()-1].get_index() as float) / (orbits[orbits.size()-1].get_parent().get_child_count() as float)
			$Sprite.modulate = Color(id, id, id)
		else:
			$Sprite.modulate = Color(0,0,0)

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
		
		if curr_orbit_behavior == ORBIT_BEHAVIOR.KEEP_IN:
			keep_body_in(curr_orbit.position, curr_orbit_radius, delta)
		elif curr_orbit_behavior == ORBIT_BEHAVIOR.PULL:
			awayFromCenter = awayFromCenter + (0 - awayFromCenter) * (delta * 0.8)
			keep_body_in(curr_orbit.position, curr_orbit_radius, delta)
		elif curr_orbit_behavior == ORBIT_BEHAVIOR.AVOID:
			keep_body_in(curr_orbit.position, curr_orbit_radius, delta)

	else:
		move_and_collide(Vector2.DOWN * 9.8)
