extends Node2D

onready var ground_enemy_path = preload("res://Entity/Ground_Enemy/Ground_Enemy.tscn")
onready var flying_enemy_path = preload("res://Entity/Flying_Enemy/Flying_Enemy.tscn")
onready var merchant_path = preload("res://Entity/Merchant/Merchant.tscn")
onready var player_hp_bar = $UI/MaxHp/CurrentHp
onready var score_counter = $UI/ScoreCounter
onready var coin_counter = $UI/CoinCounter
onready var terrain = $Terrain
onready var portal = $Portal

var noise = OpenSimplexNoise.new()
var lacunarity = 0.6
var octaves = 2
var period = 13
var persistence = 0.5
var tile = Vector2(1,1)
var rng = RandomNumberGenerator.new()

var player
var hp_bar_size
var is_hp_changed = false
var player_max_hp
var player_curr_hp
var score = 0
var coins = 0
var enemy_count
var merchant_killed = 0

var map_length = 50
var map_min_depth = 20
var level
var merchant
var merchant_is_alive

func _ready():
	player = $Player
	var player_camera = player.get_node("Camera")
	player_camera.make_current()
	player_camera.limit_left = 0
	player_camera.zoom = 0.5*player_camera.zoom
	
	player_max_hp = player.max_hp
	hp_bar_size = player_hp_bar.rect_size.x
	
	$UI/MerchantHead.visible = false
	$UI/MerchantHeadCounter.visible = false
	level = 1
	generate_terrain()
	spawn_monster()
	
	$Game_Over.visible = false
	$Shop_Screen.visible = false
	$Paused_Menu.visible = false
	merchant_is_alive = true

func _process(delta):
	$UI/MaxHp/HpLabel.bbcode_text = str("[center]", player.current_hp)
	if merchant_killed > 0:
		$UI/MerchantHead.visible = true
		$UI/MerchantHeadCounter.visible = true
		$UI/MerchantHeadCounter.text = str(" ", merchant_killed)
	score_counter.bbcode_text = str("[right]", score, " ")
	coin_counter.text = str(" ", coins)
	
	player_max_hp = player.max_hp
	is_hp_changed = player.is_hp_changed
	if is_hp_changed:
		update_player_health()
	
	if enemy_count == 0:
		portal.is_all_enemy_defeated = true
	
	if merchant_is_alive:
		merchant.enemy_count = enemy_count
		if merchant.can_sell:
			if Input.is_action_just_pressed("interact"):
				$Shop_Screen.visible = true
				$Shop_Screen.price = 30 + 5*level
				get_tree().paused = true
	
	if Input.is_action_just_pressed("pause"):
		$Paused_Menu.visible = true
		get_tree().paused = true
	
	if player.is_dead:
		yield(get_tree().create_timer(1), "timeout")
		game_over()
	
func update_player_health():
	player_curr_hp = player.current_hp
	player_hp_bar.rect_size.x = hp_bar_size * (player_curr_hp / player_max_hp)

func generate_terrain():
	terrain.clear()
	rng.randomize()
	var length = 50 + 20*level
	map_length = length
	noise.seed = rng.randi()
	noise.lacunarity = lacunarity
	noise.octaves = octaves
	noise.period = period
	noise.persistence = persistence
	
	var ground_height
	for x in range(-5, map_length + 15):
		if floor(map_length/3.0):
			ground_height = 5 + (x/floor(map_length/3.0)) * 5
		else:
			ground_height = 10 + abs(noise.get_noise_1d(x) * 3)
		var ground = 17 - abs(noise.get_noise_2d(x , 0) * ground_height)
		if x <= 0:
			ground = 5
		if x == (map_length - 7):
			spawn_merchant(x)
		if x == (map_length -2):
			move_portal(x, ground)
		if x > map_length:
			ground = 0
		terrain.set_cell(x, ground, 0)
		for y in range(ground, 35):
			terrain.set_cell(x, y, 0)
	
	terrain.update_bitmask_region(Vector2(-5,0), Vector2(map_length + 15, map_min_depth))

func spawn_merchant(x):
	var merchant_entity = merchant_path.instance()
	add_child(merchant_entity)
	merchant = merchant_entity
	merchant_entity.position.x = x*32 + 16
	merchant_entity.position.y = 0
	merchant_entity.points = 500 * pow(0.2, level)
	merchant_entity.coin_drop = 50 + 2*level

func move_portal(x,y):
	portal.position.x = x*32 + 16
	portal.position.y = (y-2)*32

func spawn_monster():
	rng.randomize()
	noise.seed = rng.randi()
	var num = 5 + level*level
	enemy_count = num
	
	var middle = map_length/2
	for x in range(num):
		var value = noise.get_noise_1d(x)
		var enemy
		if value > 0:
			enemy = ground_enemy_path.instance()
		else:
			enemy = flying_enemy_path.instance()
		add_child(enemy)
		enemy.max_hp = 10 + 10.0 * pow(0.2, level)
		enemy.current_hp = enemy.max_hp
		enemy.damage = 1 + 1 * pow(0.2, level)
		enemy.points = 100 + 100 * pow(0.2, level)
		enemy.coin_drop = 10 + 2*level
		
		rng.randomize()
		var dist_from_mid = rng.randi_range(-middle+5, middle - 5)
		var enemy_x = (middle - dist_from_mid)*32
		enemy.position = Vector2(enemy_x, 0)
		yield(get_tree().create_timer(.2), "timeout")
	pass

func reset():
	for child in get_children():
		if child.is_in_group("Coin") or child.is_in_group("Bullet") or child.is_in_group("Merchant"):
			child.queue_free()
	player.position = Vector2(140, 450)
	level += 1
	generate_terrain()
	spawn_monster()
	merchant_is_alive = true

func game_over():
	get_tree().paused = true
	$Game_Over.visible = true
	$Game_Over/ColorRect/Panel/FinalScore.bbcode_text = str("[center]your score: ", score)
