extends RigidBody2D


# Called when the node enters the scene tree for the first time.
func _ready():
	var randomtime = randf_range(0.5, 1)
	await get_tree().create_timer(randomtime).timeout
	mass *= randomtime


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
