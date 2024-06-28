extends Node2D

@export var spaceObjectScene : PackedScene
@export var targetSpaceObjectCount : int
var currentSpaceObjectCount : int = 0

func _meet_space_object_count():
	var mainArea = find_child("MainGravityArea")
	
	if (not mainArea == null) and mainArea.has_method("get_orbit_radius"):
	
		var mainAreaRadius = mainArea.get_orbit_radius()
		
		if currentSpaceObjectCount < targetSpaceObjectCount:
			var targetCount = targetSpaceObjectCount - currentSpaceObjectCount
			for i in targetCount:
				var newAwayValue = randf_range(0.2, 0.9)
				var newSpaceObject = spaceObjectScene.instantiate()
				var spawn_pos : Vector2 = mainArea.position + Vector2.from_angle(randf_range(-180, 180)) * mainAreaRadius * newAwayValue
				
				if newSpaceObject.has_method("set_away_value"):
					newSpaceObject.set_away_value(newAwayValue)
				else:
					printerr("space.gd: referencing an outdated method set_away_value()")
				
				add_child(newSpaceObject)
				(newSpaceObject as Node2D).position = spawn_pos
				currentSpaceObjectCount += 1
	
	else:
		if not (mainArea.has_method("get_orbit_radius")):
			printerr("space.gd: referencing an outdated method get_orbit_radius in MainGravityArea.gd")

# Called when the node enters the scene tree for the first time.
func _ready():
	_meet_space_object_count()
	
func _draw():
	var mainArea = find_child("MainGravityArea")
	
	if (not mainArea == null) and mainArea.has_method("get_orbit_radius"):
		var radius = mainArea.get_orbit_radius() 
		draw_arc(mainArea.position, radius, -180, 180, 64, Color.BISQUE, 4)
	else:
		printerr("space.gd: referencing an outdated method get_orbit_radius in MainGravityArea.gd")
		
	mainArea = find_child("MainGravityArea2")
	
	if (not mainArea == null) and mainArea.has_method("get_orbit_radius"):
		var radius = mainArea.get_orbit_radius() 
		draw_arc(mainArea.position, radius, -180, 180, 64, Color.AQUA, 4)
	else:
		printerr("space.gd: referencing an outdated method get_orbit_radius in MainGravityArea.gd")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
