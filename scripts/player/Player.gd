extends CharacterBody2D

var gravityAccumulated : float = 0.0
@export var characterMass: float = 10.0
@export var movementSpeed: float = 10.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _input(event):
	if event.is_action_pressed("interact"):
		print("interact pressed")

func _physics_process(delta):
	if not is_on_floor():
		gravityAccumulated += 0.98 * characterMass
		velocity.y = gravityAccumulated
		move_and_slide()
	else:
		if Input.is_action_pressed("move_l") and not Input.is_action_pressed("move_r"):
			move_and_collide(Vector2(-movementSpeed, 0))
			$PlayerSprite.flip_h = true
		elif Input.is_action_pressed("move_r") and not Input.is_action_pressed("move_l"):
			move_and_collide(Vector2(movementSpeed, 0))
			$PlayerSprite.flip_h = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
