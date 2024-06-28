extends Camera2D

var currZoom = 0
var targetFollow : Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	currZoom = zoom.x

func _on_player_ready(inPlayer):
	print("camera knows that the camera is ready")
	targetFollow = inPlayer

func _physics_process(delta):
	
	if Input.is_action_pressed("zoom_in"):
		currZoom = clampf(currZoom + 0.015, 0, 3)
		zoom.x = currZoom
		zoom.y = currZoom
		
	if Input.is_action_pressed("zoom_out"):
		currZoom = clampf(currZoom - 0.015, 0, 3)
		zoom.x = currZoom
		zoom.y = currZoom
		
	if targetFollow != null:
		position = targetFollow.position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
