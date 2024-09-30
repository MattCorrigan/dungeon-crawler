extends Node2D

@onready var GridScreen = preload("res://Scenes/GridScreen.tscn")
@onready var FightScreen = preload("res://Scenes/FightScreen.tscn")

@onready var FinishedFight = preload("res://Scenes/FinishedFight.tscn")
@onready var StartScreen = preload("res://Scenes/StartScreen.tscn")
@onready var LevelScreen = preload("res://Scenes/LevelScreen.tscn")

@onready var InventoryScreen = preload("res://Scenes/InventoryScreen.tscn")
@onready var ShopScreen = preload("res://Scenes/ShopScreen.tscn")
@onready var CharacterScreen = preload("res://Scenes/CharacterScreen.tscn")
@onready var EventScreen = preload("res://Scenes/EventScreen.tscn")

var loaded_grid
var previous
var current
var level = 1

var player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Background.z_index = 0
	var Screen = StartScreen.instantiate()
	$Players.hide()
	add_child(Screen)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func start_game():
	get_node("StartScreen").queue_free()
	player = $Players/PlayerIcon/Player
	add_grid()

func add_grid():
	$Players.show()
	var Screen = GridScreen.instantiate()
	loaded_grid = Screen
	$Players/PlayerIcon.grid = Screen
	Screen.player_icon = $Players/PlayerIcon
	Screen.level = level
	add_child(Screen)

func reset_game():
	for enemy in $Enemies.get_children():
		enemy.queue_free()
	loaded_grid.queue_free()
	var Screen = StartScreen.instantiate()
	add_child(Screen)

func next_level():
	var Screen = LevelScreen.instantiate()
	for enemy in $Enemies.get_children():
		enemy.queue_free()
	$Players.hide()
	loaded_grid.queue_free()
	level += 1
	Screen.player = player
	Screen.level = level
	add_child(Screen)

func leveled_up():
	get_node("LevelScreen").queue_free()
	add_grid()

func grid_screen_on():
	loaded_grid.refresh_data()
	for node in $Enemies.get_children():
		node.get_node("Sprite2D").show()
	$Players.show()
	loaded_grid.show()
	loaded_grid.get_node("GridHUD").show()

func grid_screen_off():
	for node in $Enemies.get_children():
		node.get_node("Sprite2D").hide()
	$Players.hide()
	loaded_grid.get_node("GridHUD").hide()
	loaded_grid.hide()

func character_screen_on():
	var Screen = CharacterScreen.instantiate()
	Screen.player = player
	grid_screen_off()
	add_child(Screen)

func character_screen_off():
	get_node("CharacterScreen").queue_free()
	grid_screen_on()

func inventory_screen_on():
	var Screen = InventoryScreen.instantiate()
	Screen.player = player
	grid_screen_off()
	add_child(Screen)

func inventory_screen_off():
	get_node("InventoryScreen").queue_free()
	grid_screen_on()

func shop_screen_on():
	var Screen = ShopScreen.instantiate()
	Screen.player = player
	grid_screen_off()
	add_child(Screen)

func shop_screen_off():
	get_node("ShopScreen").queue_free()
	grid_screen_on()

func event_screen_on(event):
	var Screen = EventScreen.instantiate()
	Screen.player = player
	Screen.current_event = event
	grid_screen_off()
	add_child(Screen)

func event_screen_off():
	get_node("EventScreen").queue_free()
	grid_screen_on()

func start_fight(current_location, previous_location, enemy_parent):
	previous = previous_location
	current = current_location
	var Screen = FightScreen.instantiate()
	Screen.enemy_parent = enemy_parent
	Screen.player = player
	
	grid_screen_off()
	
	add_child(Screen)

func end_fight(type):
	player.conditions = []
	for enemy in get_node("FightScreen").enemy_list:
		enemy.hide()
	
	get_node("FightScreen").queue_free()
	
	if type == "killed":
		loaded_grid.kill_enemy()
		player.gold += 10
		var Victory = FinishedFight.instantiate()
		Victory.get_node("CanvasLayer/Victory").show()
		add_child(Victory)
		await get_tree().create_timer(0.5).timeout
		Victory.queue_free()
		#if $Enemies.get_child_count() == 0:
			#next_level()
			#return
	
	if type == "retreat":
		loaded_grid.move_player(Vector2(previous.x, previous.y))
	
	if type == "died":
		var Defeat = FinishedFight.instantiate()
		Defeat.get_node("CanvasLayer/Defeat").show()
		add_child(Defeat)
		await get_tree().create_timer(2).timeout
		Defeat.queue_free()
		reset_game()
		return
	
	grid_screen_on()
