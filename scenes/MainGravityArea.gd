extends Area2D

var bodies_in = []

func on_body_exited(body):
	if body is PhysicsBody2D and body in bodies_in:
		bodies_in.erase(body)
		var thisname : String = body.name
		print("a planet " + thisname +  " has left the orbit!")

func on_body_enetered(body):
	if body is PhysicsBody2D:
		(body as RigidBody2D).gravity_scale = 0
		print("Found a planet!")
		bodies_in.append(body)

# Called when the node enters the scene tree for the first time.
func _ready():
	print("Gravity Area center is " + str(position))
	body_entered.connect(on_body_enetered)
	body_exited.connect(on_body_exited)
	

func push_body_along(body):
	var physBody = (body as RigidBody2D)
	var body_radius = ((physBody.get_child(0) as CollisionShape2D).shape as CircleShape2D).radius
	var alpha : float = position.distance_to(body.position) / ($CollisionShape2D.shape as CircleShape2D).radius
	var force : float = lerp(8500, 2150, alpha) * (1 / physBody.mass)
	var orbitToBody = (position - body.position).normalized().orthogonal() * force
#	physBody.move_and_collide(orbitToBody)
	physBody.apply_central_force(orbitToBody)
	
func keep_body_in(body):
	var physBody = (body as RigidBody2D)
	var myRadius = ($CollisionShape2D.shape as CircleShape2D).radius
	
	var velocity_alpha : float = clampf(physBody.linear_velocity.length() / (myRadius/2), 0.0, 1.0)
	var velocity_negate : Vector2 = physBody.linear_velocity.length() * -1 * physBody.position.direction_to(position) * velocity_alpha
	
	var targetPoint = (position.direction_to(body.position) * (myRadius/2)) + position
	var force = physBody.position.direction_to(targetPoint) * physBody.position.distance_to(targetPoint)
	physBody.apply_central_force(force - velocity_negate)
	
	if velocity_alpha < 0.45:
		push_body_along(body)
	

func _physics_process(delta):
	for body in bodies_in:
		keep_body_in(body)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	queue_redraw()
