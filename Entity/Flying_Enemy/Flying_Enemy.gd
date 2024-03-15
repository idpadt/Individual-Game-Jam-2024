extends KinematicBody2D

onready var coin_path = preload("res://Objects/Coin.tscn")
onready var exclamation = preload("res://Entity/Ground_Enemy/Sprites/Exclamation.png")
onready var question = preload("res://Entity/Ground_Enemy/Sprites/Question Mark.png")
onready var bullet_path = preload("res://Entity/Flying_Enemy/Enemy_Bullet.tscn")
onready var terrain_detector = $TerrainDetector
onready var emotion = $Emotion
onready var timer = $Timer

export (int) var GRAVITY = 30
export (int) var normal_speed = 50
export (int) var jump_speed = 30

const UP = Vector2(0,-1)
var velocity = Vector2()

var max_hp = 10.0
var current_hp
var damage = 1
var points = 100
var coin_drop = 10
var hpbar_size
var player

var is_attacking
var is_too_high
var is_passive
var is_facing_left
var time = 0
var fly_cooldown = 0

func _ready():
	hpbar_size = $Hp/CurrHp.rect_scale.x
	current_hp = max_hp
	emotion.visible = false
	is_too_high = false
	is_passive = true
	is_facing_left = false
	is_attacking = false
	player = get_parent().get_node("Player")

func _physics_process(delta):
	
	if terrain_detector.is_colliding():
		velocity.y -= delta* jump_speed 
	else:
		velocity.y += delta * GRAVITY
	
	if is_passive:
		scan_player(delta)
	
	if not is_passive:
		chase()
		if not is_attacking:
			shoot()
	
	fly(delta)
	
	velocity = move_and_slide(velocity, UP)

func hurt(damage, kb_velocity):
	velocity = kb_velocity * 0.6
	current_hp -= damage
	if current_hp <= 0:
		get_parent().enemy_count -= 1
		$AnimationPlayer.play("Death")
	update_hp()
	
	if velocity.x > 0 and not is_facing_left:
		is_facing_left = true
		flip()
	elif velocity.x < 0 and is_facing_left:
		is_facing_left = false
		flip()

func update_hp():
	var new_size = hpbar_size * (current_hp/max_hp)
	$Hp/CurrHp.rect_scale.x = new_size
	if is_passive:
		emotion.texture = question
		emotion.visible = true

func flip():
	scale.x = -scale.x
	emotion.scale.x = -emotion.scale.x
	$Hp.rect_scale.x = -$Hp.rect_scale.x

func scan_player(delta):
	time += delta
	if time > .5 and is_passive:
		time = 0
		var vector = player.global_position - global_position
		var distance = (vector.x)*(vector.x) + (vector.y)*(vector.y)
		if distance < 40000:
			is_passive = false
			emotion.texture = exclamation
			emotion.visible = true
			GRAVITY = 100
			jump_speed = 100

func fly(delta):
	if is_facing_left:
		velocity.x -= normal_speed*delta
	else:
		velocity.x += normal_speed*delta
	if is_passive:
		fly_cooldown += delta
		if fly_cooldown > 1:
			fly_cooldown = 0
			if not is_facing_left:
				is_facing_left = true
				flip()
			elif is_facing_left:
				is_facing_left = false
				flip()

func chase():
	if player.position.x < position.x and not is_facing_left:
		is_facing_left = true
		flip()
	elif player.position.x > position.x and is_facing_left:
		is_facing_left = false
		flip()
	
func shoot():
	var bullet = bullet_path.instance()
	get_tree().root.add_child(bullet)
	bullet.damage = damage
	bullet.position = global_position
	bullet.velocity = (player.global_position - bullet.position)
	
	is_attacking = true
	timer.start(1)

func drop_coin_score():
	var coin = coin_path.instance()
	coin.value = coin_drop
	get_tree().root.get_child(0).add_child(coin)
	coin.position = global_position
	get_parent().score += points
	get_parent().enemy_count -= 1

func shield():
	$AnimationPlayer.play("Shield")

func _on_Timer_timeout():
	is_attacking = false
