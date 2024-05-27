extends Node2D


onready var madeby = $ColorRect/MadeBy
onready var makaraui = $ColorRect/MakaraUI
onready var attribution = $ColorRect/Attribution

var time = 0

func _ready():

	madeby.visible = false
	makaraui.visible = false
	attribution.visible = false
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta
	
	if time >= 1.0 and time <= 4.0:
		madeby.visible = true
	elif time >= 4.0 and time <= 7.0:
		madeby.visible = false
		makaraui.visible = true
	elif time >= 7.0 and time <= 10.0:
		makaraui.visible = false
		attribution.visible = true
	elif time >= 13.0 and time <= 15.0:
		attribution.visible = false
	elif time >= 15.0:
		get_tree().change_scene("res://Scenes/MainMenu.tscn")
