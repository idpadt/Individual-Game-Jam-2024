extends Node2D


var is_cheated = false
var cheatcounter = 0
onready var timer = $Timer
var pressable = true
var time = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta
	if cheatcounter > 0 and time >= 10.0:
		cheatcounter = 0
	check_cheat()
	pass

func check_cheat():
	if pressable and Input.is_action_just_pressed("space"):
		pressable = false
		timer.start()
		cheatcounter = 0
	
	detect_secret_code("up", 0)
	detect_secret_code("down", 1)
	detect_secret_code("up",2)
	detect_secret_code("down", 3)
	detect_secret_code("left", 4)
	detect_secret_code("right",5)
	detect_secret_code("left", 6)
	detect_secret_code("right", 7)
	detect_secret_code("b",8)
	detect_secret_code("a",9)
	detect_secret_code("p",10)
	detect_secret_code("p",11)
	
	print(cheatcounter)
	
	if cheatcounter == 12 and !is_cheated:
		get_parent().coins += 100000
		cheatcounter = 0
		time = 0
		is_cheated = true
	elif cheatcounter == 12 and is_cheated:
		get_parent().coins = 0
		cheatcounter = 0
		time = 0
		is_cheated = false

func detect_secret_code(key, step):
	if pressable:
		if cheatcounter == step:
			if Input.is_action_just_pressed(key):
				cheatcounter += 1
				pressable = false
				timer.start()
				time = 0


func _on_Timer_timeout():
	pressable = true
