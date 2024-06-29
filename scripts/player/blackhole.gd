class_name Blackhole extends CharacterBody2D

const SPEED = 300.0

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
		$black_hole_rotation.rotate(deg_to_rad(1))
		if abs(rad_to_deg($black_hole_rotation.rotation)) > 360.0:
			var newRot = -sign(rad_to_deg($black_hole_rotation.rotation)) * (360 - (abs(rad_to_deg($black_hole_rotation.rotation)) - 360 ))
			$black_hole_rotation.rotation = deg_to_rad(newRot)
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

	move_and_slide()

func pause_requested():
	physics_paused = true
	paused_last_pos = position

func unapause():
	physics_paused = false
