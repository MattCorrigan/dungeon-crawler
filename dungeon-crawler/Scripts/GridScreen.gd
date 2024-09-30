extends Node2D

@onready var RoomIcon = preload("res://Scenes/RoomIcon.tscn")
@onready var Hallway = preload("res://Scenes/Hallway.tscn")
@onready var Event = preload("res://Scenes/Event.tscn")
@onready var EnemyIcon = preload("res://Scenes/EnemyIcon.tscn")
@onready var Test = preload("res://EnemyOptions/Test.tscn")
var cells : Dictionary
var hallways : Dictionary
@export var cell_spacing = 150
var player_location = Vector2(0, 0)
var spawnable_rooms = Array()
var player_icon
var level

var player_moving = false
var previous_location
var moving_to : Vector2
var t = 0.0
@export var player_icon_speed : float = 5.0

@onready var enemy_dict = {
	"Test" : preload("res://EnemyOptions/Test.tscn"),
	"Knight" : preload("res://EnemyOptions/Knight.tscn"),
	"Militia" : preload("res://EnemyOptions/Militia.tscn"),
	"Boss" : preload("res://EnemyOptions/Boss.tscn")
}

var enemy_comps1 = {
	0 : ["Test", "Test"],
	1 : ["Militia", "Militia", "Militia"],
	2 : ["Knight"]
}

@export var rooms_removed = 3
var total_rooms_wanted = 25
var entrance
var exit
var num_hallways_past_second = 0 # Counts the number of rooms that can have more than 2 hallways
@export var distance_wanted = 4

var event_spawner = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	place_room(Vector2(0, 0))
	recursive_generation(Vector2(0, 0), 4, 0.25)
	choose_entrance_and_exit()
	remove_rooms(clamp(rooms_removed-total_rooms_wanted, 0, rooms_removed))
	fill_hallways()
	remove_hallways(floor(float(num_hallways_past_second)/3))
	for i in range(6):
		spawn_enemy()
	place_enemy(exit, ["Boss"])
	for i in range(2):
		spawn_event()
	refresh_data()
	place_object(player_icon, entrance, 3)
	player_location = entrance
	explore_room(entrance)
	#print(cells.size())
	#print(total_rooms_wanted)
	#print(check_rooms_reachable())
	#print(num_hallways_past_second)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player_moving:
		t += delta * player_icon_speed
		player_icon.position = (previous_location*150).lerp(moving_to*150, t)

func choose_entrance_and_exit():
	for i in range(20):
		entrance = spawnable_rooms[randi_range(0, spawnable_rooms.size()-1)]
		exit = spawnable_rooms[randi_range(0, spawnable_rooms.size()-1)] #Distance from the entrance not based on actual walking
		if entrance.distance_to(exit) >= distance_wanted:
			break
	
	change_room_type(entrance, ["Entrance"]); change_room_type(exit, ["Exit"])
	player_location = entrance
	spawnable_rooms.erase(entrance); spawnable_rooms.erase(exit)

func recursive_generation(location : Vector2, n : int, percent : float):
	for i in range(n):
		var new_room = choose_adjacent_empty_spot(location)
		if new_room != null:
			place_room(new_room, ["Primary"])
			if percent >= randf():
				recursive_generation(new_room, n, percent)
			else:
				recursive_generation(new_room, n-1, percent)

func check_rooms_reachable(ignored_room = Vector2(9999, 9999), ignore_hallways = true, ignore_hallway = Vector2(99, 99)) -> bool:
	for cell in cells:
		cells[cell].reached = false
	recursive_check_rooms_reachable(entrance, ignored_room, ignore_hallways, ignore_hallway)
	var output = true
	for cell in cells:
		if not cells[cell].reached and not cell == ignored_room:
			output = false
	return output

func recursive_check_rooms_reachable(location : Vector2, ignored_room, ignore_hallways, ignore_hallway):
	var adjacents = get_adjacent_vectors(location)
	for adj in adjacents:
		if cells.has(adj) and not ignored_room == adj and not cells[adj].reached:
			var hallway = find_hallway(location, adj)[0]
			if ignore_hallways or (hallways.has(hallway) and not hallway == ignore_hallway):
				cells[adj].reached = true
				recursive_check_rooms_reachable(adj, ignored_room, ignore_hallways, ignore_hallway)

func remove_rooms(amount : int):
	var possible_removals = spawnable_rooms
	var current_removed = 0
	while current_removed < amount and possible_removals.size() > 0:
		var location = possible_removals.pick_random()
		if check_rooms_reachable(location):
			remove_room(location)
			current_removed += 1
		possible_removals.erase(location)

func remove_room(location : Vector2):
	var room = cells[location]
	spawnable_rooms.erase(location)
	cells.erase(location)
	room.queue_free()

func get_adjacent_vectors(location : Vector2) -> Array:
	var x = location.x
	var y = location.y
	var output = []
	output.append(Vector2(x+1, y))
	output.append(Vector2(x-1, y))
	output.append(Vector2(x, y+1))
	output.append(Vector2(x, y-1))
	return output

func choose_adjacent_empty_spot(location : Vector2):
	if cells.has(location):
		var rooms = []
		var x = location.x
		var y = location.y
		var spots = get_adjacent_vectors(location)
		for spot in spots:
			if not cells.has(spot):
				rooms.append(spot)
		
		if rooms.is_empty():
			return null
		return rooms.pick_random()

func place_room(location : Vector2, type = []):
	if not cells.has(location) and total_rooms_wanted + rooms_removed > 0:
		var new_room = RoomIcon.instantiate()
		new_room.room_array = ["Open"]
		new_room.room_array.append_array(type)
		if not type.is_empty():
			new_room.image = type[0]
		cells[location] = new_room
		place_object(new_room, location, 1)
		spawnable_rooms.append(location)
		
		$Rooms.add_child(new_room)
		total_rooms_wanted -= 1

func change_room_type(location : Vector2, type):
	var room = cells[location]
	room.room_array = ["Open"]
	room.room_array.append_array(type)
	room.image = type[0]

func fill_hallways():
	for cell in cells:
		var adjacents = get_adjacent_vectors(cell)
		var num_hallways = 0
		for adjacent in adjacents:
			if cells.has(adjacent):
				create_hallway(cell, adjacent)
				num_hallways += 1
		num_hallways_past_second += clamp(num_hallways-2, 0, 1)

func remove_hallways(amount : int):
	var possible_removals = hallways.keys()
	var current_removed = 0
	while current_removed < amount and possible_removals.size() > 0:
		var location = possible_removals.pick_random()
		if check_rooms_reachable(Vector2(9999, 9999), false, location):
			remove_hallway(location)
			current_removed += 1
		possible_removals.erase(location)

func remove_hallway(location):
	var hallway = hallways[location]
	hallways.erase(location)
	hallway.queue_free()

func find_hallway(room1 : Vector2, room2 : Vector2):
	if abs(room1.x - room2.x) == 1 and abs(room1.y - room2.y) == 0:
		var x = min(room1.x, room2.x) + 0.5
		return [Vector2(x, room1.y), "x"]
	elif abs(room1.x - room2.x) == 0 and abs(room1.y - room2.y) == 1:
		var y = min(room1.y, room2.y) + 0.5
		return [Vector2(room1.x, y), "y"]
	
func create_hallway(room1 : Vector2, room2 : Vector2):
	var array = find_hallway(room1, room2)
	place_hallway(array[0], array[1], room1, room2)

func place_hallway(location : Vector2, orientation, room1, room2):
	if not hallways.has(location):
		var new_hallway = Hallway.instantiate()
		hallways[location] = new_hallway
		new_hallway.get_node(orientation+"unexplored").show()
		cells[room1].adj_hallways.append(new_hallway)
		cells[room2].adj_hallways.append(new_hallway)
		place_object(new_hallway, location, 0)
		
		$Rooms.add_child(new_hallway)

func spawn_enemy():
	var room = spawnable_rooms[randi_range(0, spawnable_rooms.size()-1)]
	var chosen_comp
	if level <= 5:
		chosen_comp = enemy_comps1[randi_range(0, enemy_comps1.size()-1)]
	else:
		chosen_comp = ["Test"]
	place_enemy(Vector2(room.x, room.y), chosen_comp)
	spawnable_rooms.erase(room)

func place_enemy(location : Vector2, chosen_comp):
	var new_enemy = EnemyIcon.instantiate()
	new_enemy.hide()
	var room = cells[location]
	room.room_array.append("Enemy")
	room.enemy_in_room = new_enemy
	place_object(new_enemy, location, 2)
	new_enemy.cell_location = location
	for enemy in chosen_comp:
		var each_enemy = enemy_dict[enemy].instantiate()
		each_enemy.hide()
		new_enemy.add_child(each_enemy)
	
	get_parent().get_node("Enemies").add_child(new_enemy)

func kill_enemy():
	var room = cells[player_location]
	room.enemy_in_room.queue_free()
	room.room_array.erase("Enemy")

func spawn_event():
	var room = spawnable_rooms[randi_range(0, spawnable_rooms.size()-1)]
	place_event(Vector2(room.x, room.y), event_spawner%2)
	spawnable_rooms.erase(room)
	event_spawner += 1

func place_event(location, num):
	var new_event = Event.instantiate()
	new_event.create_event(num)
	new_event.hide()
	var room = cells[location]
	room.room_array.append("Event")
	room.event_in_room = new_event
	place_object(new_event, location, 2)
	new_event.cell_location = location
	
	get_parent().get_node("Events").add_child(new_event)

func move_player(location : Vector2):
	var hallway = find_hallway(player_location, location)
	if is_open(location) and hallways.has(hallway[0]):
		previous_location = player_location
		t = 0.0
		player_moving = true
		moving_to = location
		await get_tree().create_timer(1/player_icon_speed).timeout
		player_moving = false
		
		place_object(player_icon, location, 3)
		player_location = location
		explore_room(location)
		explore_hallway(hallway)
		if cells[player_location].room_array.has("Exit"):
			$GridHUD/ExitFloor.show()
		else:
			$GridHUD/ExitFloor.hide()
		if cells[player_location].room_array.has("Event"):
			cells[player_location].room_array.erase("Event")
			get_parent().event_screen_on(cells[player_location].event_in_room)
		if cells[player_location].room_array.has("Enemy"):
			get_parent().start_fight(player_location, previous_location, cells[player_location].enemy_in_room)

func explore_room(location : Vector2):
	var room = cells[location]
	#if room.get_node("Unexplored").is_visible():
	if room.is_visible():
		room.get_node("Unexplored").hide()
		room.get_node(room.image).show()
		show_adjacent_hallways(location)
		if room.enemy_in_room != null:
			room.enemy_in_room.show()
			room.enemy_in_room.explored = true

func show_adjacent_hallways(location : Vector2):
	var adjacent = get_adjacent_vectors(location)
	for adj in adjacent:
		if cells.has(adj):
			var room = cells[adj]
			var hallway = find_hallway(location, adj)
			if hallways.has(hallway[0]):
				hallways[hallway[0]].show()
				if room.get_node(room.image).is_visible():
					explore_hallway(hallway)

func explore_hallway(hallway):
	hallways[hallway[0]].get_node(hallway[1]+"unexplored").hide()
	hallways[hallway[0]].get_node(hallway[1]).show()

func place_object(object, location : Vector2, z):
	var x = centered_x(object, location.x)
	var y = centered_y(object, location.y)
	object.position = Vector2(x, y)
	object.z_index = z

func centered_x(object, x):
	return x*cell_spacing #- object.get_node("Sprite2D").texture.get_width()/2

func centered_y(object, y):
	return y*cell_spacing #- object.get_node("Sprite2D").texture.get_height()/2

func is_open(location : Vector2):
	if cells.has(location):
		if cells[location].room_array.has("Open"):
			return true
	return false

func refresh_data():
	$GridHUD.get_node("PlayerHealth").text = "Health: " + str(player_icon.get_node("Player").health)
	$GridHUD.get_node("PlayerMana").text = "Mana: " + str(player_icon.get_node("Player").mana)
	$GridHUD.get_node("PlayerBarrier").text = "Barrier: " + str(player_icon.get_node("Player").barrier)
	$GridHUD.get_node("PlayerGold").text = "Gold: " + str(player_icon.get_node("Player").gold)
