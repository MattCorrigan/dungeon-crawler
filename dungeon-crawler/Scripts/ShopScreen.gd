extends CanvasLayer

@onready var Item = preload("res://Scenes/Item.tscn")

var cost_checker
var player
var currently_selected_id = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	cost_checker = Item.instantiate()
	add_child(cost_checker)
	for button in $ScrollC/GridC.get_children():
		button.custom_minimum_size.x = 238
		button.custom_minimum_size.y = 70
	refresh_data()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func refresh_data():
	disable_buttons()
	if not currently_selected_id == null and player.gold >= cost_checker.get_cost(currently_selected_id):
		$Buy.show()
		change_description()
	else:
		$Buy.hide()
		$Description.text = ""

func _on_back_s_pressed() -> void:
	get_parent().shop_screen_off()


func disable_buttons():
	$ScrollC/GridC/Healing.set_disabled(player.gold < cost_checker.get_cost("healing_potion"))
	$ScrollC/GridC/Mana.set_disabled(player.gold < cost_checker.get_cost("mana_potion"))
	$ScrollC/GridC/Cleansing.set_disabled(player.gold < cost_checker.get_cost("cleansing_potion"))


func _on_healing_pressed() -> void:
	select_item("healing_potion")

func _on_mana_pressed() -> void:
	select_item("mana_potion")

func _on_cleansing_pressed() -> void:
	select_item("cleansing_potion")

func select_item(id):
	currently_selected_id = id
	change_description()
	$Buy.show()

func change_description():
	$Description.text = cost_checker.get_description(currently_selected_id)

func _on_buy_pressed() -> void:
	player.gain_item(currently_selected_id, 1)
	player.gold -= cost_checker.get_cost(currently_selected_id)
	refresh_data()
