extends Node3D
var is_fullscreen: bool = true
var is_pause: bool = false
var PauseText: Label = null

func _ready():
	DisplayServer.window_set_mode(3)
	PauseText = get_node("../PauseText")
	PauseText.text = ""


func _process(delta):
	if Input.is_action_just_pressed("screen"):
		is_fullscreen = !is_fullscreen
		if is_fullscreen:
			DisplayServer.window_set_mode(3) # フルスクリーン
		else:
			DisplayServer.window_set_mode(0) # ウィンドウモード
	if Input.is_action_just_pressed("pause"):
		is_pause = !is_pause
		if is_pause:
			PauseText.text = "Pause :press r key retry"
		else:
			PauseText.text = ""
		get_tree().paused = is_pause
	if Input.is_action_just_pressed("reload"):
		get_tree().reload_current_scene()
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
		

