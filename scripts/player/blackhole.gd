extends CharacterBody2D

const SPEED = 300.0

var is_player : bool = true

signal player_ready(in_player)

func _ready():
	player_ready.emit(self)

func _physics_process(delta: float) -> void:
	if $black_hole_rotation != null:
		$black_hole_rotation.rotation += 0.1
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
