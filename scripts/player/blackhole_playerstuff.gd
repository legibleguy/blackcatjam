extends Node2D

var time_started = false

func start_timer(inTime : float):
	$GameOverTimer.wait_time = inTime
	$GameOverTimer.start()
	
	var minutes : int = floori($GameOverTimer.time_left / 60)
	var seconds : int = clampi($GameOverTimer.time_left - minutes * 60, 0, 59)
	var str_mins : String = str("%0*d" % [2, minutes])
	var str_secs : String = str("%0*d" % [2, seconds])
	$CanvasLayer/VBoxContainer/TimeLabel.text = str_mins + ":" + str_secs
	$CanvasLayer/VBoxContainer/TimeLabel.visible = true
	time_started = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if time_started and not $GameOverTimer.paused:
		var minutes : int = floori($GameOverTimer.time_left / 60)
		var seconds : int = clampi($GameOverTimer.time_left - minutes * 60, 0, 59)
		var str_mins : String = str("%0*d" % [2, minutes])
		var str_secs : String = str("%0*d" % [2, seconds])
		$CanvasLayer/VBoxContainer/TimeLabel.text = str_mins + ":" + str_secs

func pause_requested():
		$GameOverTimer.paused = true
		$CanvasLayer/VBoxContainer/TimeLabel.visible = false
	

func unpause():
	if time_started:
		$GameOverTimer.paused = false
		$CanvasLayer/VBoxContainer/TimeLabel.visible = true
