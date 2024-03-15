extends KinematicBody2D

var velocity = Vector2(0,0)
var speed = 1000
var damage = 1

func _physics_process(delta):
	var collision = move_and_collide(velocity.normalized() * delta * speed)
	
	if collision:
		if collision.collider.name == "Terrain":
			$CPUParticles2D.emitting = true
			yield(get_tree().create_timer(.05), "timeout")
			queue_free()
		elif collision.collider.is_in_group("Ground_Enemy"):
			queue_free()
			collision.collider.shield()
		elif collision.collider.is_in_group("Flying_Enemy"):
			queue_free()
			collision.collider.hurt(damage, velocity/10)
		elif collision.collider.is_in_group("Merchant"):
			queue_free()
			collision.collider.hurt(damage)
