extends Area2D

var damage 

func _ready():
	damage = get_parent().damage
	pass 

func _on_GroundEnemyHand_body_entered(body):
	if body.is_in_group("Player"):
		var velocity = body.global_position - global_position
		body.hurt(damage, velocity*30)
	pass # Replace with function body.
