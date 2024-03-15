extends Area2D


var is_all_enemy_defeated = false

func _ready():
	pass

func _process(delta):
	if not is_all_enemy_defeated:
		modulate = Color("#ff0000")
	else:
		modulate = Color("#ffffff")


func _on_Portal_body_entered(body):
	if is_all_enemy_defeated and body.is_in_group("Player"):
		get_parent().reset()
