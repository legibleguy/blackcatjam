extends Node2D
@export_group("Planets Spawn")
@export var spaceObjectScene : PackedScene
@export var targetSpaceObjectCount : int
@export var numRadiusSubdivisions : int = 5
@export var startSpawnAngle : float = 40
@export var planetTexturesPool : Array[Texture] = []
var currentSpaceObjectCount : int = 0

@export_group("Tutorials")
@export var tut0 : PackedScene

@export_group("Player Player Spawn")
@export var playerScene : PackedScene
@export var playerRelatedStuffScene : PackedScene
var playerStuffReference
var playerReference

var currentLevel : int = 0
var currentTargetPlanets : int = 8
const NUM_LEVELS = 5

func _on_level_timeout():
	get_tree().change_scene_to_file("res://scenes/end.tscn")
#	currentLevel += 1
#	_play_cutscene(currentLevel)

func _post_cutscene_level_init():
	$AudioStreamPlayer.play()
	if currentLevel == 0:
		_initialize_planets()
		_initialize_player()
		playerStuffReference.start_timer(60)
		playerReference.add_child(tut0.instantiate())
	elif currentLevel == 1:
		pass
	elif currentLevel == 2:
		pass
	elif currentLevel == 3:
		pass
	else:
		get_tree().change_scene_to_file("res://scenes/menu.tscn")

func _initialize_player():
	var mainArea = find_child("MainGravityArea")
	
	if (not mainArea == null) and mainArea.has_method("get_orbit_radius"):
		var orbit_pos = mainArea.position
		var orbit_radius = mainArea.get_orbit_radius()
		if playerScene != null:
			var spawnscale = 1.5
			var spawndir : Vector2 = Vector2.UP * ((float(floor(numRadiusSubdivisions/2)) + 0.25)) / float(numRadiusSubdivisions) * orbit_radius
			var playerObject : Node2D = playerScene.instantiate()
			var playerRelatedStuffRef : Node2D = playerRelatedStuffScene.instantiate()
			add_child(playerObject)
			playerObject.add_child(playerRelatedStuffRef)
			playerObject.position = orbit_pos + spawndir
			playerObject.scale = Vector2(spawnscale, spawnscale)
			
			playerRelatedStuffRef.position = Vector2.ZERO
			
			playerReference = playerObject
			playerStuffReference = playerRelatedStuffRef
			
			var gameovertimer = playerStuffReference.find_child("GameOverTimer")
			if gameovertimer != null and (gameovertimer as Timer) != null:
				print("Timeout event registered")
				gameovertimer.timeout.connect(_on_level_timeout)

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
				var spawn_scale = randf_range(0.6, 1.6)

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
				newSpaceObject.position = spawn_pos
				newSpaceObject.scale = Vector2(spawn_scale, spawn_scale)
				
				if planetTexturesPool.size() > 0:
					newSpaceObject.find_child("Sprite").texture = planetTexturesPool.pick_random()
	else:
		if mainArea == null:
			printerr("Couldn't find MainGravityArea")
		elif not (mainArea.has_method("get_orbit_radius")):
			printerr("space.gd: referencing an outdated method get_orbit_radius in MainGravityArea.gd")

func _play_cutscene(idx : int):
	if $AudioStreamPlayer.playing:
		$AudioStreamPlayer.stop()
	
	for child in get_children(true):
		if child.is_in_group("pauseable"):
			if child.has_method("pause_requested"):
				child.pause_requested()
	
	if playerReference != null:
		var camera_ref = playerReference.find_child("PlayerCamera")
		if camera_ref != null:
			(camera_ref as Camera2D).enabled = false
	$cutscenePlayer/Main/Camera2D.enabled = true
	$cutscenePlayer.init_cutscene(idx)

func _cutscene_over():
	for child in get_children(true):
		if child.is_in_group("pauseable"):
			if child.has_method("unpause"):
				child.unpause()
	
	$cutscenePlayer/Main/Camera2D.enabled = false
	
	if playerReference != null:
		var camera_ref = playerReference.find_child("PlayerCamera")
		if camera_ref != null:
			(camera_ref as Camera2D).enabled = true
			print("camera re enabled")
	
	print("cutscene over")
	_post_cutscene_level_init()

func _audio_loop_finished():
	if !$cutscenePlayer.active:
		$AudioStreamPlayer.play()

# Called when the node enters the scene tree for the first time.
func _ready():
	RenderingServer.set_default_clear_color(Color(0.1,0.1,0.1))
	$cutscenePlayer.cutscene_over.connect(_cutscene_over)
	$AudioStreamPlayer.finished.connect(_audio_loop_finished)
	
	_play_cutscene(currentLevel)

func _physics_process(delta):
	if $ParallaxBackground/ColorRect.material != null and playerReference != null:
		$ParallaxBackground/ColorRect.material.set("shader_parameter/refpos", Vector4(-playerReference.position.x, -playerReference.position.y, 0, 0))
	
func _draw():
	return
	var mainArea = find_child("MainGravityArea")
	
	if (not mainArea == null) and mainArea.has_method("get_orbit_radius"):
		var radius = mainArea.get_orbit_radius() 
		draw_arc(mainArea.position, radius, -180, 180, 64, Color.BISQUE, 4)
	else:
		printerr("space.gd: referencing an outdated method get_orbit_radius in MainGravityArea.gd")
