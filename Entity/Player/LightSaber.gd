extends Area2D

var damage = 1

func _ready():
	pass

func _on_LightSaber_body_entered(body):
	var velocity = get_global_mouse_position() - global_position
	if body.is_in_group("Ground_Enemy"):
		body.hurt(damage, velocity*3)
	elif body.is_in_group("Flying_Enemy"):
		body.shield()
	elif body.is_in_group("Merchant"):
		body.hurt(damage)
