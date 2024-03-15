extends RigidBody2D


var value = 0

func _ready():
	pass


func _on_Coin_body_entered(body):
	if body.is_in_group("Player"):
		get_parent().coins += value
		queue_free()
	pass # Replace with function body.
