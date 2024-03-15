extends KinematicBody2D

onready var coin_path = preload("res://Objects/Coin.tscn")
onready var exclamation = preload("res://Entity/Ground_Enemy/Sprites/Exclamation.png")
onready var question = preload("res://Entity/Ground_Enemy/Sprites/Question Mark.png")
onready var animation = $AnimationPlayer
onready var terrain_detector = $TerrainDetector
onready var player_detector = $PlayerDetector
onready var emotion = $Emotion

export (int) var GRAVITY = 1500
export (int) var normal_speed = 50
export (int) var jump_speed = 400

const UP = Vector2(0,-1)
var velocity = Vector2()

var max_hp = 10.0
var current_hp
var damage = 1
var jumps = 3
var points = 100
var coin_drop = 10
var hpbar_size
var player

var is_knocked = false
var is_facing_left = false
var is_moving = true
var is_passive = true
var is_attacking = false
var is_jumping = false
var is_dead = false

func _ready():
	hpbar_size = $Hp/CurrentHp.rect_scale.x
	current_hp = max_hp
	emotion.visible = false

func _physics_process(delta):
	velocity.y += delta * GRAVITY
	
	if is_jumping and is_on_floor():
		is_jumping = false
	if terrain_detector.enabled:
		check_terrain()
	
	if player_detector.is_colliding() and is_passive:
		is_passive = false
		player = player_detector.get_collider()
		normal_speed = 200
		emotion.visible = true
		emotion.texture = exclamation
	elif not is_passive:
		chase()
		if player_detector.is_colliding() and not is_attacking:
			melee()
	
	if not is_knocked and is_moving:
		if is_facing_left:
			velocity.x -= normal_speed*delta
		else:
			velocity.x += normal_speed*delta
	
	if is_knocked:
		stabilize_knockback(delta)
	
	velocity = move_and_slide(velocity, UP)

func stabilize_knockback(delta):
	if velocity.x < 5:
		is_knocked = false
	if velocity.x != 0:
		velocity.x = velocity.x + (0 - velocity.x) * (5*delta)

func hurt(damage, kb_velocity):
	$Blood.restart()
	velocity = kb_velocity * 0.6
	is_knocked = true
	
	# Face the direction of the damage source
	if velocity.x > 0 and not is_facing_left:
		is_facing_left = true
		scale.x = -scale.x
	elif velocity.x < 0 and is_facing_left:
		is_facing_left = false
		scale.x = -scale.x
	
	current_hp -= damage
	if current_hp <= 0 and not is_dead:
		is_dead = true
		is_moving = false
		drop_coin_score()
		animation.play("Death")
		yield(get_tree().create_timer(.4), "timeout")
		queue_free()
	update_hp()

func update_hp():
	var new_size = hpbar_size * (current_hp/max_hp)
	$Hp/CurrentHp.rect_scale.x = new_size
	if is_passive:
		emotion.visible = true
		emotion.texture = question

func melee():
	$Cooldown.start(2)
	is_attacking = true
	animation.play("Melee")
	yield(get_tree().create_timer(.18), "timeout")
	animation.play("RESET")

func check_terrain():
	if terrain_detector.is_colliding():
		terrain_detector.enabled = false
		if jumps > 0 and not is_jumping:
			velocity.y -= jump_speed
			is_jumping = true
			if is_passive:
				jumps -= 1
		elif jumps == 0 and is_passive and not is_jumping:
			jumps = 3
			if is_facing_left:
				is_facing_left = false
				flip()
			else:
				is_facing_left = true
				flip()
		terrain_detector.enabled = true

func check_player():
	if player_detector.is_colliding():
		velocity.x = 0
		melee()
		is_moving = false
	else:
		is_moving = true

func chase():
	if player.position.x < position.x and not is_facing_left:
		is_facing_left = true
		flip()
	elif player.position.x > position.x and is_facing_left:
		is_facing_left = false
		flip()

func flip():
	scale.x = -scale.x
	emotion.scale.x = -emotion.scale.x
	$Hp.rect_scale.x = -$Hp.rect_scale.x

func drop_coin_score():
	var coin = coin_path.instance()
	coin.value = coin_drop
	get_tree().root.get_child(0).add_child(coin)
	coin.position = global_position
	get_parent().score += points
	get_parent().enemy_count -= 1

func shield():
	animation.play("Shield")

func _on_Cooldown_timeout():
	is_attacking = false
