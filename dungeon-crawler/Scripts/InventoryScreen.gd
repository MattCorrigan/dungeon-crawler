extends CanvasLayer

var player
var currently_selected = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for button in $ScrollC/GridC.get_children():
		button.custom_minimum_size.x = 238
		button.custom_minimum_size.y = 70
	refresh_data()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func refresh_data():
	set_amounts()
	disable_buttons()
	if not currently_selected == null and currently_selected.quantity > 0:
		$Use.show()
		change_description()
	else:
		$Use.hide()
		$Description.text = ""

func set_amounts():
	$ScrollC/GridC/Healing.text = "Healing Potion: " + str(player.get_item_quantity("healing_potion"))
	$ScrollC/GridC/Mana.text = "Mana Potion: " + str(player.get_item_quantity("mana_potion"))
	$ScrollC/GridC/Cleansing.text = "Cleansing Potion: " + str(player.get_item_quantity("cleansing_potion"))


func disable_buttons():
	$ScrollC/GridC/Healing.set_disabled(player.get_item_quantity("healing_potion") == 0)
	$ScrollC/GridC/Mana.set_disabled(player.get_item_quantity("mana_potion") == 0)
	$ScrollC/GridC/Cleansing.set_disabled(player.get_item_quantity("cleansing_potion") == 0)


func _on_back_i_pressed() -> void:
	get_parent().inventory_screen_off()


func _on_healing_pressed() -> void:
	select_item("healing_potion")

func _on_mana_pressed() -> void:
	select_item("mana_potion")

func _on_cleansing_pressed() -> void:
	select_item("cleansing_potion")

func select_item(id):
	currently_selected = player.find_item(id)
	change_description()
	$Use.show()


func change_description():
	$Description.text = currently_selected.description


func _on_use_pressed() -> void:
	currently_selected.consume()
	refresh_data()
