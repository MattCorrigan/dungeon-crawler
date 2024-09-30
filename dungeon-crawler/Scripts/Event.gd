extends Node2D

var cell_location : Vector2
var event_name
var message
var choice1
var choice2

var player

var all_events = {
	0 : ["healing", "You come across a well full of healing water", "Drink from it", "Bottle some for later"],
	1 : ["mana", "You come across a basin with mana-restoring water", "Drink from it", "Bottle some for later"]
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func create_event(num):
	var dict_array = all_events[num]
	event_name = dict_array[0]
	message = dict_array[1]
	choice1 = dict_array[2]
	choice2 = dict_array[3]

func choose_1():
	if event_name == "healing":
		player.health = player.max_health
	elif event_name == "mana":
		player.mana = player.max_mana

func choose_2():
	if event_name == "healing":
		player.gain_item("healing_potion", 1)
	elif event_name == "mana":
		player.gain_item("mana_potion", 1)
