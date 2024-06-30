extends Node2D


func _physics_process(delta):
	var idx = 0
	var scale_val = remap(clampi(get_child_count(), 0, 20), 1, 20, 0.5, 0.09)
	for child in get_children():
		if child is Sprite2D:
			var angle = 360 / get_child_count() * idx
			var targetPos = Vector2.UP.rotated(angle) * $"../EatPlanetWarningArea2D/CollisionShape2D".shape.radius
			child.position.x = child.position.x + (targetPos.x - child.position.x) * (delta * 2)
			child.position.y = child.position.y + (targetPos.y - child.position.y) * (delta * 2)
			
			child.scale.x = child.scale.x + (scale_val - child.scale.x) * (delta * 2)
			child.scale.y = child.scale.y + (scale_val - child.scale.y) * (delta * 2)
			
			idx += 1
