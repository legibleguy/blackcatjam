extends Control

var cursor_def = load("res://scenes/menu/cursor_default.png")
var cursor_point = load("res://scenes/menu/cursor_highlight.png")
	

func _start_pressed():
#	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	print("pressed")
	$Sprite2D.visible = true
	$AnimationPlayer.play("fade_in")

# Called when the node enters the scene tree for the first time.
func _ready():
	RenderingServer.set_default_clear_color(Color(1,1,1))
	
#	Input.set_custom_mouse_cursor(cursor_def)
#	Input.set_custom_mouse_cursor(cursor_point, Input.CURSOR_POINTING_HAND)
	
	var start_button = get_node("Start")
	if start_button != null:
		(start_button as Button).pressed.connect(_start_pressed)
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var start_button = get_node("Start")
	if start_button != null:
		if (start_button as Button).is_hovered():
			Input.set_custom_mouse_cursor(cursor_point, Input.CURSOR_POINTING_HAND)


func _on_animation_player_animation_finished(anim_name):
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	get_tree().change_scene_to_file("res://scenes/space.tscn")
	
