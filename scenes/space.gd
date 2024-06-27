extends Node2D

@export var spaceObjectScene : PackedScene
@export var targetSpaceObjectCount : int
var currentSpaceObjectCount : int = 0

func _meet_space_object_count():
	var mainAreaRadius = ($"MainGravityArea/CollisionShape2D".shape as CircleShape2D).radius
	if currentSpaceObjectCount < targetSpaceObjectCount:
		var targetCount = targetSpaceObjectCount - currentSpaceObjectCount
		for i in targetCount:
			var newSpaceObject = spaceObjectScene.instantiate()
			var ran : float = randf_range(-mainAreaRadius, mainAreaRadius)
			var spawn_pos : Vector2 = Vector2(ran, -mainAreaRadius)
#			newSpaceObject.initialize(self, spawn_pos)
			
			add_child(newSpaceObject)
			(newSpaceObject as Node2D).position = spawn_pos
			currentSpaceObjectCount += 1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_meet_space_object_count()
	pass
