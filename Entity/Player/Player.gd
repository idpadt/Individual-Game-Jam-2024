extends KinematicBody2D

onready var sprite = $Player
onready var cshape = $Cshape
onready var camera = $Camera
onready var animation = $Animation/AnimationPlayer
onready var timer = $Timer
onready var hand = $Hand

export (int) var GRAVITY = 1500
export (int) var player_speed = 200
export (int) var jump_speed = -500
var melee = preload("res://Entity/Player/LightSaber.tscn")
var ranged = preload("res://Entity/Player/Blaster.tscn")

const UP = Vector2(0,-1)
var velocity = Vector2()
var is_attacking = false
var is_knocked = false
var facing_left = false
var max_hp = 10.0
var current_hp
var is_hp_changed = false
var melee_damage = 1
var ranged_damage = 1

var is_dead = false

func _ready():
	hand.change_to(ranged, ranged_damage)
	current_hp = max_hp
	pass

func _process(delta):
	if current_hp <= 0 and not is_dead:
		is_dead = true
		animation.play("Death")
	pass

func _physics_process(delta):
	velocity.y += delta * GRAVITY
	get_input(delta)
	
	velocity = move_and_slide(velocity, UP)

func get_input(delta):
	if not is_knocked:
		velocity.x = 0
		check_jump()
		check_left()
		check_right()
	
	check_melee()
	check_ranged()
	look_at_mouse()
	
	if is_knocked:
		stabilize_knockback(delta)

func check_jump():
	if Input.is_action_just_pressed("up") or Input.is_action_just_pressed("space"):
		if is_on_floor():
			velocity.y = jump_speed

func check_left():
	if Input.is_action_pressed("left"):
		velocity.x -= player_speed

func check_right():
	if Input.is_action_pressed("right"):
		velocity.x += player_speed
	
func check_melee():
	if Input.is_action_just_pressed("mouse2") and not is_attacking:
		is_attacking = true
		timer.start(.5)
		hand.is_animating = true
		hand.change_to(melee, melee_damage)
		animation.play("Melee")
		yield(get_tree().create_timer(.18), "timeout")
		hand.is_animating = false
		hand.change_to(ranged, ranged_damage)
		animation.play("RESET")

func check_ranged():
	if Input.is_action_just_pressed("mouse1") and not is_attacking:
		is_attacking = true
		timer.start(.2)
		hand.shoot()

func look_at_mouse():
	if not hand.is_animating:
		var mouse_pos = get_global_mouse_position()
		if mouse_pos.x > position.x and facing_left:
			facing_left = false
			scale.x = -scale.x
			pass
		
		if mouse_pos.x < position.x and not facing_left:
			facing_left = true
			scale.x = -scale.x
			pass
		pass

func hurt(damage, kb_velocity):
	velocity = kb_velocity
	velocity.y = velocity.y /3
	current_hp -= damage
	is_knocked = true
	is_hp_changed = true

func stabilize_knockback(delta):
	if velocity.x < 10:
		is_knocked = false
	elif velocity.x != 0:
		velocity.x = velocity.x + (0 - velocity.x) * (10*delta)

func _on_Timer_timeout():
	is_attacking = false
	pass # Replace with function body.
