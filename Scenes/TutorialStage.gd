extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var player = $Player
	var player_camera = player.get_node("Camera")
	player_camera.make_current()
	player_camera.limit_left = 0
	player_camera.zoom = 0.5*player_camera.zoom


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Portal_body_entered(body):
	if body.is_in_group("Player"):
		get_tree().change_scene("res://Scenes/MainLevel.tscn")
