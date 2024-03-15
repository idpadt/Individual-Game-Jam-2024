extends CanvasLayer


var player
var player_coin
var price

func _ready():
	player = get_parent().get_node("Player")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$BgDimmer/ShopBox/RichTextLabel2.bbcode_text = str("[center]Price: ", price)


func _on_Melee_pressed():
	player_coin = get_parent().coins
	
	if player_coin >= price:
		get_parent().coins = player_coin - price
		player.melee_damage += 1


func _on_Range_pressed():
	player_coin = get_parent().coins
	
	if player_coin >= price:
		get_parent().coins = player_coin - price
		player.ranged_damage += 1


func _on_Health_pressed():
	player_coin = get_parent().coins
	
	if player_coin >= price:
		get_parent().coins = player_coin - price
		player.max_hp += 10.0
		player.current_hp = player.max_hp


func _on_Exit_pressed():
	get_tree().paused = false
	visible = false
