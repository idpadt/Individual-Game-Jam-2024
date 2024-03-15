extends Node2D

onready var bulletPath = preload("res://Entity/Player/Bullet.tscn")
var damage =1

func _ready():
	pass
	
func _process(delta):
	pass

func shoot():
	var bullet = bulletPath.instance()
	get_tree().root.add_child(bullet)
	bullet.damage = damage
	bullet.position = $Position2D.global_position
	bullet.velocity = get_global_mouse_position() - bullet.position
	bullet.look_at(get_global_mouse_position())
