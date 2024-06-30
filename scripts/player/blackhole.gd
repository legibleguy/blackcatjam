class_name Blackhole extends CharacterBody2D

enum ORBIT_BEHAVIOR {PULL, PUSH, KEEP_IN, AVOID}

const SPEED = 300.0
const SPINSPEED : float = 3.34

var is_player : bool = true
var physics_paused: bool = false
var paused_last_pos : Vector2 = Vector2.ZERO

var planets_to_eat : Array = []
var planets_to_keep : Array = []
var planets_collected : int = 0

signal player_ready(in_player)
signal planet_collected()

func _draw():
	return
	draw_arc(Vector2.ZERO, $KeepPlanetArea2D/CollisionShape2D.shape.radius, -180, 180, 16, Color.RED, 3)
	draw_arc(Vector2.ZERO, $EatPlanetWarningArea2D/CollisionShape2D.shape.radius, -180, 180, 16, Color.ORANGE, 3)
	draw_arc(Vector2.ZERO, $EatPlanetArea2D/CollisionShape2D.shape.radius, -180, 180, 16, Color.YELLOW, 3)

func _ready():
	player_ready.emit(self)

func _physics_process(delta: float) -> void:
	
	if physics_paused:
		position = paused_last_pos
		return
	
	queue_redraw()
	
	if $black_hole_rotation != null:
		$black_hole_rotation.rotate(deg_to_rad(-SPINSPEED))
		$black_hole_rotation/BlackHoleSprite/BlackHoleSpriteInner.rotate(deg_to_rad(-SPINSPEED))
		
		if abs(rad_to_deg($black_hole_rotation/BlackHoleSprite/BlackHoleSpriteInner.rotation)) > 360.0:
			var newRot = -sign(rad_to_deg($black_hole_rotation/BlackHoleSprite/BlackHoleSpriteInner.rotation)) * (360 - (abs(rad_to_deg($black_hole_rotation/BlackHoleSprite/BlackHoleSpriteInner.rotation)) - 360 ))
			$black_hole_rotation/BlackHoleSprite/BlackHoleSpriteInner.rotation = deg_to_rad(newRot)
		
		if abs(rad_to_deg($black_hole_rotation/BlackHoleSprite/BlackHoleSpriteInner.rotation)) > 360.0:
			var newRot = -sign(rad_to_deg($black_hole_rotation/BlackHoleSprite/BlackHoleSpriteInner.rotation)) * (360 - (abs(rad_to_deg($black_hole_rotation/BlackHoleSprite/BlackHoleSpriteInner.rotation)) - 360 ))
			$black_hole_rotation/BlackHoleSprite/BlackHoleSpriteInner.rotation = deg_to_rad(newRot)
	else:
		printerr("blackhole.gd: couldn't access $black_hole_rotation node")

	if Input.is_action_pressed("move_l") and not Input.is_action_pressed("move_r"):
		velocity.x = -SPEED
	elif Input.is_action_pressed("move_r") and not Input.is_action_pressed("move_l"):
		velocity.x = SPEED
	else:
		velocity.x = 0
	
	if Input.is_action_pressed("move_u") and not Input.is_action_pressed("move_d"):
		velocity.y = -SPEED
	elif Input.is_action_pressed("move_d") and not Input.is_action_pressed("move_u"):
		velocity.y = SPEED
	else:
		velocity.y = 0
	
	if Input.is_action_just_pressed("interact"):
		$MainGravityArea.set_orbit_behavior(ORBIT_BEHAVIOR.PULL)
	else:
		if !Input.is_action_pressed("interact") and $MainGravityArea.get_orbit_behavior() == ORBIT_BEHAVIOR.PULL:
			for body in ($MainGravityArea as Area2D).get_overlapping_bodies():
				if body in planets_to_eat:
					var targetSprite = (body.find_child("Sprite") as Sprite2D)
					if targetSprite:
						targetSprite.z_index = -1
						targetSprite.modulate = Color(0.85,0.85,0.85,0.5)
						targetSprite.reparent($CollectedPlanets)
					body.queue_free()
					continue
				
				body.stop_eat_warning()
				body.force_leave_orbit()
			
			planets_to_keep.clear()
			planets_to_eat.clear()
			
			$MainGravityArea.set_orbit_behavior(ORBIT_BEHAVIOR.AVOID)
	move_and_slide()

func pause_requested():
	var playerStuffRef = get_node("PlayerStuff")
	if playerStuffRef != null:
		playerStuffRef.pause_requested()
	
	print("player: pause received!")
	physics_paused = true
	paused_last_pos = position
	set_process(false)

func unpause():
	var playerStuffRef = get_node("PlayerStuff")
	if playerStuffRef != null:
		playerStuffRef.unpause()

	print("player: unpause received!")
	physics_paused = false
	set_process(true)


func _on_keep_planet_area_2d_body_entered(body):
	if $MainGravityArea.get_orbit_behavior() != ORBIT_BEHAVIOR.PULL:
		return
		
#	if body.is_in_group("planets"):
#		planets_to_keep.push_back(body)


func _on_eat_planet_area_2d_body_entered(body):
	if $MainGravityArea.get_orbit_behavior() != ORBIT_BEHAVIOR.PULL:
		return
		
	if body.is_in_group("planets"):
		if body in planets_to_keep:
			planets_to_keep.erase(body)
		body.queue_free()


func _on_eat_planet_warning_area_2d_body_entered(body):
	if $MainGravityArea.get_orbit_behavior() != ORBIT_BEHAVIOR.PULL:
		return
		
	if body.is_in_group("planets"):
		if body.has_method("play_eat_warning"):
			planets_to_eat.push_back(body)
			body.play_eat_warning()
		else:
			printerr("Trying to warn planet about getting eaten but play_eat_warning is not implemented")


func _on_keep_planet_area_2d_body_exited(body):
	if $MainGravityArea.get_orbit_behavior() != ORBIT_BEHAVIOR.PULL:
		return
		
	if body.is_in_group("planets"):
		body.force_leave_orbit()


func _on_eat_planet_area_2d_body_exited(body):
	pass # Replace with function body.


func _on_eat_planet_warning_area_2d_body_exited(body):
	if $MainGravityArea.get_orbit_behavior() != ORBIT_BEHAVIOR.PULL:
		return

	if body.is_in_group("planets"):
		if body.has_method("stop_eat_warning"):
			if body in planets_to_eat:
				planets_to_eat.erase(body)
			body.stop_eat_warning()
		else:
			printerr("Trying to warn planet about getting eaten but stop_eat_warning is not implemented")
