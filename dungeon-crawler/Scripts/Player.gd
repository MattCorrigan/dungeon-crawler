extends Node2D

@onready var Item = preload("res://Scenes/Item.tscn")

var conditions = []

var endurance = 1
var health : int
var max_health : int
var protection : float

var strength = 1
var damage : int
var crit_chance : float
var crit_damage : float

var magic = 1
var mana : int
var max_mana : int
var spell_damage : int

var agility = 1
var evasion : float
var speed : float

var barrier : int

var inventory : Array
var gold : int

var skills_main = ["attacks", "spells", "potions"] #Retreat is always the fourth option
var skills = ["stab", "slash", "strike", "lightning", "fireball", "frostbolt", "healing", "mana", "cleansing"]
#var skills_1 = ["Stab", "Slash", ""]
#var skills_2 = ["Fireball", "Frostbolt", ""]
#var skills_3 = ["Healing", "", ""]

var linearize_gain = {
	0 : 0,
	1 : 0.16666666666667,
	2 : 0.11904761904762,
	3 : 0.08928571428571,
	4 : 0.06944444444444,
	5 : 0.05555555555556,
	6 : 0.04545454545455,
	7 : 0.03787878787879,
	8 : 0.03205128205128,
	9 : 0.02747252747253,
	10 : 0.02380952380952,
	11 : 0.02083333333333,
	12 : 0.01838235294118,
	13 : 0.01633986928105,
	14 : 0.01461988304094,
	15 : 0.01315789473684
}

var linearize_crit = {
	0 : 0,
	1 : 3.0242017380337365,
	2 : 4.721156938624265,
	3 : 6.045970419947993,
	4 : 7.170810505396249,
	5 : 8.165702545668797,
	6 : 9.067392275372912,
	7 : 9.898009019250155,
	8 : 10.67210420128244,
	9 : 11.399852331289086,
	10 : 12.088698552434973,
	11 : 12.744285424123108,
	12 : 13.371010519499624,
	13 : 13.972380100888525,
	14 : 14.55124323109386,
	15 : 15.109952298580943
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health = 10
	max_health = health
	protection = 0.0
	
	damage = 2
	crit_chance = 0.0
	crit_damage = 0.5
	
	mana = 5
	max_mana = mana
	spell_damage = 2
	
	evasion = 0.0
	speed = 2.0
	
	barrier = 0
	gain_item("healing_potion", 1)
	#gain_item("mana_potion", 1)
	gold = 0
	
	#var previous = 0.0
	#for i in range(16.0):
		#var value = 5.0/(5.0+i)
		#print(value)
		#print(1-value)
		#print(1-value-previous)
		#print(1/value)
		#previous = 1-value

func gain_item(id, add_quantity):
	var item = find_item(id)
	if not item == null:
		item.quantity += add_quantity
	else:
		var new_item = Item.instantiate()
		new_item.create_item(id, add_quantity)
		inventory.append(new_item)
		new_item.player = self
		add_child(new_item)

func find_item(id):
	for i in inventory:
		if i.item_id == id:
			return i
	return null

func get_item_quantity(id) -> int:
	var item = find_item(id)
	if not item == null:
		return item.quantity
	return 0

# ENDURANCE
func gain_endurance():
	endurance += 1
	gain_health(5)
	#gain_protection(linearize_gain[endurance-1])

func gain_health(amount):
	max_health += amount
	health += amount

func gain_protection(amount):
	protection = clamp(protection + amount, 0.0, 0.75)

# STRENGTH
func gain_strength():
	strength += 1
	gain_damage(1)
	#var multiplier = linearize_crit[strength-1] - linearize_crit[strength-2]
	#gain_crit_chance(0.066*multiplier)
	#gain_crit_damage(0.166*multiplier)
	
	#print(crit_chance * (1+crit_damage) + (1-crit_chance))
	#print(0.066*n * (1.5+0.166*n) + (1-0.066*n))

func gain_damage(amount):
	damage += amount

func gain_crit_chance(amount):
	crit_chance = clamp(crit_chance + amount, 0.0, 1.0)

func gain_crit_damage(amount):
	crit_damage += amount

# MAGIC
func gain_magic():
	magic += 1
	gain_mana(1)
	gain_spell_damage(1)

func gain_mana(amount):
	max_mana += amount
	mana += amount

func gain_spell_damage(amount):
	spell_damage += amount

# AGILITY
func gain_agility():
	agility += 1
	gain_speed(1)
	#gain_evasion(linearize_gain[agility-1])

func gain_speed(amount):
	speed += amount

func gain_evasion(amount):
	evasion = clamp(evasion + amount, 0.0, 0.75)

func gain_skill():
	pass

func gain_trait():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
