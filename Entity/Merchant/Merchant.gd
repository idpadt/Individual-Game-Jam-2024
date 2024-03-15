extends KinematicBody2D


onready var alert_icon = preload("res://Entity/Merchant/Sprites/Exclamation.png")
onready var heart_icon = preload("res://Entity/Merchant/Sprites/Heart Icon.png")
onready var fear_icon = preload("res://Entity/Merchant/Sprites/Fear Icon.png")
onready var coin_path = preload("res://Objects/Coin.tscn")

onready var emotion_icon = $Emotion

const UP = Vector2(0,-1)
var velocity = Vector2()
export (int) var GRAVITY = 1500

var max_hp = 50.0
var points = 500
var coin_drop = 100
var curr_hp
var hp_bar_size
var in_fear
var in_alert
var can_sell
var enemy_count
var is_dead = false

func _ready():
	in_fear = true
	in_alert = false
	curr_hp = max_hp
	$HpBar.visible = false
	hp_bar_size = $HpBar/CurrentHp.rect_scale.x

func _process(delta):
	enemy_count = get_parent().enemy_count
	
	if in_fear:
		emotion_icon.texture = fear_icon
	elif in_alert:
		emotion_icon.texture = alert_icon
	else:
		emotion_icon.texture = heart_icon
	
	if not in_fear and not in_alert:
		can_sell = true
	else:
		can_sell = false
	
	if enemy_count == 0:
		in_fear = false
	
	if curr_hp == 0 and not is_dead:
		is_dead = true
		get_parent().merchant_is_alive = false
		drop_score()
		queue_free()

func _physics_process(delta):
	velocity.y += delta * GRAVITY
	velocity = move_and_slide(velocity, UP)

func hurt(damage):
	if not in_fear:
		in_alert = true
		$HpBar.visible = true
		curr_hp -= damage
		update_hp()

func update_hp():
	var new_size = hp_bar_size * (curr_hp/max_hp)
	$HpBar/CurrentHp.rect_scale.x = new_size

func drop_score():
	var coin = coin_path.instance()
	coin.value = coin_drop
	get_tree().root.get_child(0).add_child(coin)
	coin.position = global_position
	get_parent().score += points
	get_parent().merchant_killed += 1
