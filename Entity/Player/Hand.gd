extends Node2D

var is_animating = false
var weapon

onready var weapon_pos = $WeaponPos

func _ready():
	pass

func _process(delta):
	if not is_animating:
		look_at(get_global_mouse_position())
	pass

func change_to(weap_name,damage):
	if weapon != null:
		weapon.queue_free()
	weapon = weap_name.instance()
	add_child(weapon)
	weapon.damage = damage
	weapon.show_behind_parent = true
	weapon.position = weapon_pos.position
	pass

func shoot():
	weapon.shoot()
