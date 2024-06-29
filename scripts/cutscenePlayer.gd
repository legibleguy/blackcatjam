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
	if !proceed():
		end_curr_cutscene()

func end_curr_cutscene():
	active = false
	$Main.visible = false
	cutscene_over.emit()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func proceed() -> bool:
	var result : bool = false
	currFrame += 1
	if cutscenes.size() > currCutsceneIdx:
		var currCutscene = (cutscenes[currCutsceneIdx] as Cutscene)
		if currCutscene != null:
			if currCutscene.cutsceneFrames.size() > currFrame:
				var frame : CutsceneFrame = (currCutscene.cutsceneFrames[currFrame] as CutsceneFrame)
				if frame != null:
					$Main/Sprite2D.texture = frame.cutsceneSheet
					$Main/Label.text = frame.cutsceneCaption
					result = true
	return result

func _physics_process(delta):
	if active and Input.is_action_just_pressed("interact"):
		if !proceed():
			end_curr_cutscene()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
