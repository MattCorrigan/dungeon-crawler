extends Node2D

var item_id
var item_name
var description
var gold_cost
var effect
var quantity = 0

var player

var all_items = {
	"healing_potion" : ["Healing Potion", "Heals half the player's total HP", 10, "healing"],
	"mana_potion" : ["Mana Potion", "Restores half the player's total mana", 10, "mana"],
	"cleansing_potion" : ["Cleansing Potion", "Removes all the player's debuffs", 10, "cleansing"]
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_cost(id):
	return all_items[id][2]

func get_description(id):
	return all_items[id][1]

func create_item(id, add_quantity):
	item_id = id
	var dict_array = all_items[id]
	item_name = dict_array[0]
	description = dict_array[1]
	gold_cost = dict_array[2]
	effect = dict_array[3]
	quantity = add_quantity

func consume():
	quantity -= 1
	var skill = Callable(self, effect)
	skill.call()


func healing():
	player.health = clamp(player.health + player.max_health/2, 0, player.max_health)

func mana():
	player.mana = clamp(player.mana + player.max_mana/2, 0, player.max_mana)

func cleansing():
	player.conditions = []
