extends Node2D
@export_group("Planets Spawn")
@export var spaceObjectScene : PackedScene
@export var targetSpaceObjectCount : int
@export var numRadiusSubdivisions : int = 5
@export var startSpawnAngle : float = 40
var currentSpaceObjectCount : int = 0

@export_group("Player Player Spawn")
@export var playerScene : PackedScene

func _initialize_player(orbit_pos, orbit_radius):
	if playerScene != null:
		var spawndir : Vector2 = Vector2.UP * ((float(floor(numRadiusSubdivisions/2)) + 0.25)) / float(numRadiusSubdivisions) * orbit_radius
		var playerObject : Node2D = playerScene.instantiate()
		add_child(playerObject)
		playerObject.position = orbit_pos + spawndir

func _initialize_planets():
	var mainArea = find_child("MainGravityArea")
	
	if (not mainArea == null) and mainArea.has_method("get_orbit_radius"):
	
		var mainAreaRadius = mainArea.get_orbit_radius()

		for i in range(1, numRadiusSubdivisions):
			var awayFactor : float = float(i) / float(numRadiusSubdivisions)
			var currRadius = mainAreaRadius * awayFactor
			
			var targetAngle = startSpawnAngle / i
			var numAngles = 360/targetAngle
			for angleIdx in range(numAngles):
				
				var currAngle = targetAngle * angleIdx
				var spawnDirection = Vector2.UP.rotated(currAngle)
				var spawn_pos = spawnDirection * currRadius + mainArea.position

				var newSpaceObject = spaceObjectScene.instantiate()
				
				if newSpaceObject.has_method("set_away_value"):
					newSpaceObject.set_away_value(awayFactor)
				else:
					printerr("space.gd: referencing an outdated method set_away_value()")
					
				if newSpaceObject.has_method("set_away_value_keep_in"):
					newSpaceObject.set_away_value_keep_in(awayFactor)
				else:
					printerr("space.gd: referencing an outdated method set_away_value_keep_in()")
				
				add_child(newSpaceObject)
				(newSpaceObject as Node2D).position = spawn_pos
		_initialize_player(mainArea.position, mainAreaRadius)
	else:
		if mainArea == null:
			printerr("Couldn't find MainGravityArea")
		elif not (mainArea.has_method("get_orbit_radius")):
			printerr("space.gd: referencing an outdated method get_orbit_radius in MainGravityArea.gd")

# Called when the node enters the scene tree for the first time.
func _ready():
	_initialize_planets()
	
func _draw():
	var mainArea = find_child("MainGravityArea")
	
	if (not mainArea == null) and mainArea.has_method("get_orbit_radius"):
		var radius = mainArea.get_orbit_radius() 
		draw_arc(mainArea.position, radius, -180, 180, 64, Color.BISQUE, 4)
	else:
		printerr("space.gd: referencing an outdated method get_orbit_radius in MainGravityArea.gd")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
