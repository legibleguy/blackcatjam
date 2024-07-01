class_name Orbit2D extends Area2D

var bodies_in = []

enum ORBIT_BEHAVIOR {PULL, PUSH, KEEP_IN, AVOID}
@export var orbitBehavior = ORBIT_BEHAVIOR.KEEP_IN

func set_orbit_behavior(newBehavior : ORBIT_BEHAVIOR):
	orbitBehavior = newBehavior
	for body in get_overlapping_bodies():
		if body.has_method("on_orbit_behavior_changed"):
			body.on_orbit_behavior_changed(self)

func get_orbit_behavior() -> ORBIT_BEHAVIOR:
	return orbitBehavior

func get_orbit_radius(ignore_scale = false) -> float:
	if ignore_scale:
		return ($CollisionShape2D.shape as CircleShape2D).radius
	else:
		return ($CollisionShape2D.shape as CircleShape2D).radius * scale.x

func on_body_entered(body):
	if body.has_method("_on_entered_orbit"):
		body._on_entered_orbit(self)

func on_body_exited(body):
	if body.has_method("_on_exit_orbit"):
		body._on_exit_orbit(self)

# Called when the node enters the scene tree for the first time.
func _ready():
	body_entered.connect(on_body_entered)
	body_exited.connect(on_body_exited)
