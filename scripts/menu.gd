extends Node2D

func _start_pressed():
	print("pressed")
	get_tree().change_scene_to_file("res://scenes/space.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	var start_button = get_node("Start")
	if start_button != null:
		(start_button as Button).pressed.connect(_start_pressed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
