class_name Blackhole extends CharacterBody2D

enum ORBIT_BEHAVIOR {PULL, PUSH, KEEP_IN, AVOID}

const SPEED = 300.0
const SPINSPEED : float = 3.34

var is_player : bool = true
var physics_paused: bool = false
var paused_last_pos : Vector2 = Vector2.ZERO

signal player_ready(in_player)

func _ready():
	player_ready.emit(self)

func _physics_process(delta: float) -> void:
	
	if physics_paused:
		position = paused_last_pos
		return
	
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
	
	if Input.is_action_pressed("move_u") and not Input.is_action_pressed("move_d"):
		velocity.y = -SPEED
	elif Input.is_action_pressed("move_d") and not Input.is_action_pressed("move_u"):
		velocity.y = SPEED
	
	if Input.is_action_just_pressed("interact"):
		$MainGravityArea.set_orbit_behavior(ORBIT_BEHAVIOR.PULL)
	elif Input.is_action_just_released("interact"):
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
