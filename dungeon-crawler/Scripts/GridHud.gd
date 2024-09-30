extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_character_pressed() -> void:
	if not get_parent().player_moving and get_parent().is_visible_in_tree():
		get_parent().get_parent().character_screen_on()


func _on_inventory_pressed() -> void:
	if not get_parent().player_moving and get_parent().is_visible_in_tree():
		get_parent().get_parent().inventory_screen_on()


func _on_shop_pressed() -> void:
	if not get_parent().player_moving and get_parent().is_visible_in_tree():
		get_parent().get_parent().shop_screen_on()


func _on_exit_floor_pressed() -> void:
	if not get_parent().player_moving and get_parent().is_visible_in_tree():
		get_parent().get_parent().next_level()
