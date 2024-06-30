extends Node

var active : bool = false
var currFrame : int = -1
var currCutsceneIdx : int = 0

@export_category("Cutscene DB")
@export var cutscenes : Array[Cutscene] = []

signal cutscene_over

func init_cutscene(idx : int):
	active = true
	currCutsceneIdx = idx
	currFrame = -1
	$Main.visible = true
	$Main/CanvasLayer.visible = true
	$AudioStreamPlayerIntro.play()
	if !proceed():
		end_curr_cutscene()

func end_curr_cutscene():
	$AudioStreamPlayerLoop.stop()
	$AudioStreamPlayerIntro.stop()
	
	active = false
	$Main.visible = false
	$Main/CanvasLayer.visible = false
	cutscene_over.emit()

func _audio_intro_finished():
	$AudioStreamPlayerLoop.play()

func _audio_loop_finished():
	$AudioStreamPlayerLoop.play()

# Called when the node enters the scene tree for the first time.
func _ready():
	$AudioStreamPlayerIntro.finished.connect(_audio_intro_finished)
	$AudioStreamPlayerLoop.finished.connect(_audio_loop_finished)

func proceed() -> bool:
	var result : bool = false
	currFrame += 1
	if cutscenes.size() > currCutsceneIdx:
		var currCutscene = (cutscenes[currCutsceneIdx] as Cutscene)
		if currCutscene != null:
			if currCutscene.cutsceneFrames.size() > currFrame:
				var frame : CutsceneFrame = (currCutscene.cutsceneFrames[currFrame] as CutsceneFrame)
				if frame != null:
					find_child("Sprite2D").texture = frame.cutsceneSheet
					find_child("Label").text = frame.cutsceneCaption
					$AudioStreamPlayerPageFlip.play()
					result = true
				
				var bg = null
				if frame.customBackground != null:
					bg = frame.customBackground
				elif currCutscene.cutsceneBackground != null:
					bg = currCutscene.cutsceneBackground
				
				if bg != null:
					$Main/CanvasLayer/CenterContainerBG/Background.texture = bg
	return result

func _physics_process(delta):
	if active and Input.is_action_just_pressed("interact"):
		if !proceed():
			end_curr_cutscene()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
