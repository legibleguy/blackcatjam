extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
#	await get_tree().create_timer(3).timeout
	$AnimationPlayer.play("blip", -1, 0.65)
	await get_tree().create_timer(5).timeout
	$section1.visible = false
	$section2.visible = true
	await get_tree().create_timer(10).timeout
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
