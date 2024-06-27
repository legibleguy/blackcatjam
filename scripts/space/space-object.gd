class_name SpaceObject extends RigidBody2D

enum ORBIT_BEHAVIOR {PULL, PUSH, KEEP_IN, AVOID}

var orbits = []

func _get_curr_orbit():
	return orbits[0]

func _get_body_radius() -> float:
	return ($HitCollision.shape as CircleShape2D).radius

func _on_entered_orbit(body):
	if body.is_in_group("orbits"):
		linear_velocity = Vector2(0,0)
		orbits.push_front(body)
		var id : float = 50 * (body.get_index() as float) / (body.get_parent().get_child_count() as float)
		$Sprite.modulate = Color(id, id, id)

func _on_exit_orbit(body):
	if body.is_in_group("orbits") and body in orbits:
		orbits.erase(body)
		if orbits.size() > 0:
			var id : float = 50 * (orbits[0].get_index() as float) / (orbits[0].get_parent().get_child_count() as float)
			$Sprite.modulate = Color(id, id, id)
		else:
			$Sprite.modulate = Color(0,0,0)

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

func keep_body_in(orbit_pos, orbit_radius):
	var velocity_alpha : float = clampf(linear_velocity.length() / (orbit_radius/2), 0.0, 1.0)
	var velocity_negate : Vector2 = linear_velocity.length() * -1.34 * position.direction_to(orbit_pos) * velocity_alpha
	
	var targetPoint = (orbit_pos.direction_to(position) * (orbit_radius/2)) + orbit_pos
	var force = position.direction_to(targetPoint) * position.distance_to(targetPoint)
	apply_central_force(force - velocity_negate)
	
	if velocity_alpha < 0.45:
		push_body_along(orbit_pos, orbit_radius)

func pull_body_in(orbit_pos, orbit_radius):
	var velocity_alpha : float = clampf(linear_velocity.length() / (orbit_radius/2), 0.0, 1.0)
	var velocity_negate : Vector2 = linear_velocity.length() * -1.34 * position.direction_to(orbit_pos) * velocity_alpha
	
	var targetPoint = (orbit_pos.direction_to(position) * (orbit_radius/2)) + orbit_pos
	var force = position.direction_to(targetPoint) * position.distance_to(targetPoint)
	apply_central_force(force - velocity_negate)
	
	if velocity_alpha < 0.45:
		push_body_along(orbit_pos, orbit_radius)

func _physics_process(delta):
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
			keep_body_in(curr_orbit.position, curr_orbit_radius)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
