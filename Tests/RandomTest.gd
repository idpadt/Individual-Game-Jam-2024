extends Node2D


onready var tilemap = $TileMap

var noise = OpenSimplexNoise.new()
var lacunarity = 0.6
var octaves = 2
var period = 13 #13
var persistence = 0.5



func _ready():
	repeat()
	#make_pretty()
	set_lacunarity_counter()
	set_octaves_counter()
	set_period_counter()
	set_persistence_counter()
	pass

func repeat():
	#test_generation()
	test_gen_2()
	make_pretty()
	yield(get_tree().create_timer(1), "timeout")
	repeat()

func make_noise_image():
	var noise = OpenSimplexNoise.new()
	noise.seed = 5 #randi()
	noise.octaves = 4
	noise.period = 50.0
	noise.persistence = 0.75
	
	make_image(noise, "noise_base")
	
	noise.octaves = 6
	make_image(noise, "noise_+2_octave")
	noise.octaves = 2
	make_image(noise, "noise_-2_octave")
	noise.octaves = 4
	
	noise.period = 75.0
	make_image(noise, "noise_+50%_period")
	noise.period = 25.0
	make_image(noise, "noise_-50%_period")
	noise.period = 50.0
	
	noise.persistence = 1.0
	make_image(noise, "noise_+0.25_persistence")
	noise.persistence = 0.5
	make_image(noise, "noise_-0.25_persistence")
	noise.persistence = 0.75
	
	noise.octaves = 2
	noise.period = 75.0
	noise.persistence = 0.5
	make_image(noise, "noise_modified")

func make_image(noise, image_name):
	var image = noise.get_image(500, 500)
	image.save_png(str("res://Tests/"+ image_name +".png"))

func tilemap_test():
	tilemap.clear()
	var cell_id = tilemap.get_cell(1, 0)
	print(cell_id)
	
	var tile_array = tilemap.tile_set.get_tiles_ids()
	for tile in tile_array:
		print(tile)
	
	var selected_tile = Vector2(1,0)
	tilemap.set_cell(0, 0, 0, false, false, false, selected_tile)
	pass

func set_tile(x, y, selected_tile):
	tilemap.set_cell(x, y, 0, false, false, false, selected_tile)
	pass

func test_generation():
	tilemap.clear()
	var tile = Vector2(1, 1)
	noise.seed = randi()
	noise.lacunarity = lacunarity
	noise.octaves = octaves
	noise.period = period
	noise.persistence = persistence
	for x in range(60):
		for y in range(35):
			var noise_value = noise.get_noise_2d(x*2, y*2)
			if y > 25:
				noise_value += (0.4)
			if y < 25:
				noise_value -= (0.15)
			if y < 10:
				noise_value -= (0.15)
			if y < 15:
				noise_value -= (0.15)
			if noise_value > 0:
				set_tile(x, y, tile)

func test_gen_2():
	tilemap.clear()
	var tile = Vector2(1,1)
	noise.seed = randi()
	noise.lacunarity = lacunarity
	noise.octaves = octaves
	noise.period = period
	noise.persistence = persistence
	var ground = 0
	var ground_min_1 = 0
	var ground_min_2 = 0
	var ground_height = 0
	for x in range(50):
		if x < 50:
			ground_height = 5 + x/10
		else:
			ground_height = 10 + abs(noise.get_noise_1d(x) * 3)
		
		if x >= 2:
			ground_min_2 = ground_min_1
		if x >= 1:
			ground_min_1 = ground
		ground = floor(27 - abs(noise.get_noise_2d(x , 0) * ground_height))
		
		
				#print("deleted single tile")
#		if x > 1:
#			print(ground)
#			print(ground_min_1)
#			print(ground_min_2)
#			if ground == ground_min_2 and ground_min_1 > ground:
#				tilemap.set_cell(x-1, ground_min_1, -1)
#				print("deleted single tile")
			
		set_tile(x, ground, tile)
		for y in range(ground, 35):
			set_tile(x, y, tile)
		
		if x>=2:
			if ground == ground_min_2 and ground_min_1 > ground:
				tilemap.set_cell(x-2, ground_min_2, -1)
	

func make_pretty():
	var cell_pos_array = tilemap.get_used_cells()
	for cell_pos in cell_pos_array:
		var cell_type = determine_cell(cell_pos)
		set_tile(cell_pos.x, cell_pos.y, cell_type)
	pass

func determine_cell(cell_pos):
	var near_cell_pos = cell_pos
	var top_filled = false
	var bot_filled = false
	
	near_cell_pos.y -= 1
	top_filled = check_filled(near_cell_pos)
	
	near_cell_pos.y += 2
	bot_filled = check_filled(near_cell_pos)
	
	if top_filled and bot_filled:
		return Vector2(1, 1)
	elif top_filled:
		return Vector2(1, 2)
	else:
		return Vector2(1, 0)

func check_filled(cell_pos):
	var num = tilemap.get_cellv(cell_pos)
	if num == -1:
		return false
	else:
		return true

func set_lacunarity_counter():
	$Control/lacunarity_counter.text = str(lacunarity)

func set_octaves_counter():
	$Control/octaves_counter.text = str(octaves)

func set_period_counter():
	$Control/period_counter.text = str(period)

func set_persistence_counter():
	$Control/persistence_counter.text = str(persistence)

func _on_lacunarity_pressed():
	lacunarity += 0.1
	set_lacunarity_counter()

func _on_octaves_pressed():
	octaves += 1
	set_octaves_counter()

func _on_period_pressed():
	period += 1
	set_period_counter()

func _on_persistence_pressed():
	persistence += 0.1
	set_persistence_counter()

func _on_lacunarity_min_pressed():
	if lacunarity > 0.1:
		lacunarity -= 0.1
	set_lacunarity_counter()

func _on_octaves_min_pressed():
	if octaves > 1:
		octaves -= 1
	set_octaves_counter()

func _on_period_min_pressed():
	if period > 1:
		period -= 1
	set_period_counter()

func _on_persistence_min_pressed():
	if persistence > 0.1:
		persistence -= 0.1
	set_persistence_counter()
