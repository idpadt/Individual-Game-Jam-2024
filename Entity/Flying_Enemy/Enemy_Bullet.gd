extends KinematicBody2D

var velocity = Vector2(0,0)
var speed = 150
var damage = 1

func _physics_process(delta):
	$CPUParticles2D.direction = -velocity
	var collision = move_and_collide(velocity.normalized() * delta * speed)
	
	if collision:
		if collision.collider.name == "Terrain":
			queue_free()
		elif collision.collider.is_in_group("Player"):
			queue_free()
			collision.collider.hurt(damage, velocity)
