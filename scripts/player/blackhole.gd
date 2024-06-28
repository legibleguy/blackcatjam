extends CharacterBody2D

const SPEED = 300.0

var is_player : bool = true

signal player_ready(in_player)

func _ready():
	player_ready.emit(self)
	
	if is_player:
		var startup_anim = Animation.new()
		var track_index = startup_anim.add_track(Animation.TYPE_VALUE)
		startup_anim.track_set_path(track_index, "BlackHoleSprite:position:x")
		startup_anim.track_insert_key(track_index, 0.0, 0.0)
		startup_anim.track_insert_key(track_index, 2.0, 255.0)
		startup_anim.length = 2.0
		startup_anim.value_track_set_update_mode(track_index, Animation.UPDATE_CAPTURE)
		
		var animplayer = AnimationPlayer.new()
		var lib = AnimationLibrary.new()
		lib.add_animation("startup", startup_anim)
		
		animplayer.add_animation_library("lib", lib)
		animplayer.play("startup")
		

func _physics_process(delta: float) -> void:

	if Input.is_action_pressed("move_l") and not Input.is_action_pressed("move_r"):
		velocity.x = -SPEED
	elif Input.is_action_pressed("move_r") and not Input.is_action_pressed("move_l"):
		velocity.x = SPEED
	
	if Input.is_action_pressed("move_u") and not Input.is_action_pressed("move_d"):
		velocity.y = -SPEED
	elif Input.is_action_pressed("move_d") and not Input.is_action_pressed("move_u"):
		velocity.y = SPEED

	move_and_slide()
