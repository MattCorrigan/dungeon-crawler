extends Node2D

@onready var condition_scene = preload("res://Scenes/Condition.tscn")

var enemy_parent
var player
var player_list = []
var enemy_list = []
var target_enemy = 0

var turn_order = []
var turn = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_player()
	player_list.append(player)
	enemy_list = enemy_parent.get_children()
	enemy_list.pop_front()
	for i in range(enemy_list.size()):
		place_enemy(enemy_list[i], i)
	enemy_list[0].targeted()
	turn_order.append([player, player.speed+float(randi_range(0, 4))+0.8])
	for enemy in enemy_list:
		turn_order.append([enemy, enemy.speed+randf_range(0, 4.7)])
	turn_order.sort_custom(turn_sort)
	turn_manager()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

### SETUP
func turn_sort(a, b):
	if a[1] > b[1]:
		return true
	return false

func set_player():
	pass
	#player.health = get_parent().player_health
	#player.mana = get_parent().player_mana
	#player.inventory = get_parent().player_inventory

func place_enemy(enemy, num):
	enemy.fight_node = self
	enemy.health_bar = num+1
	var healthbar = $HUD.get_node("EnemyHP" + str(enemy.health_bar))
	var health = $HUD.get_node("EnemyHealth" + str(enemy.health_bar))
	enemy.position.y = -120
	
	if enemy_list.size() == 1:
		enemy.position.x = 0
	
	elif enemy_list.size() == 2:
		enemy.position.x = (150 * (num)) - 75
	
	else:
		enemy.position.x = (150 * (num)) - 150
	
	health.position.x += enemy.position.x; healthbar.position.x += enemy.position.x
	#health.position.y = enemy.position.y + 460; healthbar.position.y = enemy.position.y + 440
	
	if enemy.alive:
		enemy.show()
		$HUD.get_node("EnemyHP" + str(enemy.health_bar)).show()
		$HUD.get_node("EnemyHealth" + str(enemy.health_bar)).show()
	else:
		enemy.hide()
		$HUD.get_node("EnemyHP" + str(enemy.health_bar)).hide()
		$HUD.get_node("EnemyHealth" + str(enemy.health_bar)).hide()



### INPUTS
func change_target_enemy(enemy_node):
	enemy_list[target_enemy].get_node("Targeting").stop()
	enemy_list[target_enemy].get_node("Targeting").hide()
	
	target_enemy = enemy_list.find(enemy_node)
	refresh_target()



### ATTACKS
func stab_enabled():
	return true

func stab():
	player_attack_enemy([enemy_list[target_enemy]], player.damage)
	end_turn()

func slash_enabled():
	return true

func slash():
	player_attack_enemy([enemy_list[target_enemy]], player.damage/2, [["bleed", "damage", -player.damage/2, 3]])
	end_turn()

func strike_enabled():
	return true

func strike():
	entity_take_condition(player, "strike", "buff", 0, 2)
	entity_take_condition(player, "stun", "debuff", 0, 2)
	end_turn()

### SPELLS
func lightning_enabled() -> bool:
	return player.mana >= 1

func lightning():
	player.mana -= 1
	player_attack_enemy([enemy_list[target_enemy]], player.spell_damage * 2)
	end_turn()


func fireball_enabled() -> bool:
	return player.mana >= 1

func fireball():
	player.mana -= 1
	player_attack_enemy([enemy_list[target_enemy]], player.spell_damage)
	var enemy_choices = []
	for enemy in enemy_list:
		if enemy.alive and not enemy_list.find(enemy) == target_enemy:
			enemy_choices.append(enemy)
	if enemy_choices.size() > 0:
		player_attack_enemy([enemy_choices.pick_random()], player.spell_damage)
	end_turn()

func frostbolt_enabled() -> bool:
	return player.mana >= 1

func frostbolt():
	player.mana -= 1
	player_attack_enemy([enemy_list[target_enemy]], player.spell_damage/2, [["stun", "debuff", 0, 2]])
	end_turn()



### POTIONS
func healing_enabled():
	var item = player.find_item("healing_potion")
	return (not item == null and item.quantity > 0)

func healing():
	player.gain_item("healing_potion", -1)
	player_take_healing(player.max_health/2)
	refresh_data()
	#end_turn()


func mana_enabled():
	var item = player.find_item("mana_potion")
	return (not item == null and item.quantity > 0)

func mana():
	player.gain_item("mana_potion", -1)
	player_take_mana(player.max_mana/2)
	refresh_data()
	#end_turn()


func cleansing_enabled():
	var item = player.find_item("cleansing_potion")
	return (not item == null and item.quantity > 0)

func cleansing():
	player.gain_item("cleansing_potion", -1)
	player.conditions = []
	refresh_data()
	#end_turn()


### RETREAT
func retreat():
	get_parent().end_fight("retreat")



### TURNS
func turn_manager():
	refresh_data()
	var current_turn = turn
	turn += 1
	if turn >= turn_order.size():
		turn = 0
	
	if turn_order[current_turn][0] == player:
		start_turn()
	else:
		enemy_turn(turn_order[current_turn][0])

func player_attack_enemy(enemies, amount, conditions = []):
	for enemy in enemies:
		var modified_crit_chance = player.crit_chance
		if check_conditions(player, "CritUp"):
			modified_crit_chance += 0.25
		enemy_take_damage(enemy, amount, modified_crit_chance >= randf())
		for condition in conditions:
			entity_take_condition(enemy, condition[0], condition[1], condition[2], condition[3])

func enemy_take_damage(enemy, amount, crit = false):
	enemy.health = clamp(enemy.health - amount, 0, enemy.health)
	if not is_enemy_dead(enemy) and crit:
		enemy.health = clamp(enemy.health - int(amount*player.crit_damage), 0, enemy.health)
		is_enemy_dead(enemy)
	elif crit:
		entity_take_condition(player, "CritUp", "buff", 0, 2)
		print("Crit Overkill -- Give CritUp -- +25% for 1 turn")

func entity_take_condition(entity, e_n, t, a, d):
	var condition = condition_scene.instantiate()
	condition.effect_name = e_n
	condition.type = t
	condition.amount = a
	condition.duration = d
	entity.add_child(condition)
	entity.conditions.append(condition)

func take_condition_damage(entity) -> bool:
	var net_life = 0
	for condition in entity.conditions:
		net_life += condition.amount
	entity.health = clamp(entity.health + net_life, 0, entity.max_health)
	if not entity == player:
		return is_enemy_dead(entity)
	return false

func check_conditions(entity, wanted) -> bool:
	for condition in entity.conditions:
		if condition.effect_name == wanted:
			return true
	return false

func remove_condition(condition):
	condition.get_parent().conditions.erase(condition)
	condition.queue_free()

func is_enemy_dead(enemy) -> bool:
	if enemy.health <= 0:
		$HUD.get_node("EnemyHP" + str(enemy.health_bar)).hide()
		$HUD.get_node("EnemyHealth" + str(enemy.health_bar)).hide()
		enemy.hide()
		enemy.alive = false
		#enemy.queue_free
		#enemy_parent.get_child(number+1).queue_free()
		
		if fight_over():
			get_parent().end_fight("killed")
			return true
		
		while (not enemy_list[target_enemy].alive):
			target_enemy += 1
			if target_enemy == enemy_list.size():
				target_enemy = 0
		enemy_list[target_enemy].targeted()
		return true
	return false

func fight_over() -> bool:
	var end_fight = true
	for e in enemy_list:
		if e.alive:
			end_fight = false
			break
	return end_fight

func enemy_attack_player(players, amount):
	for player_target in players:
		if not player_target.evasion >= randf():
			var reduced = float(amount) * (1 - player_target.protection)
			if reduced - int(reduced) >= randf():
				reduced += 1.0
			player_take_damage(player_target, floor(reduced))
		else:
			print("Dodged!")

func player_take_damage(player_target, amount):
	var pierced = clamp(amount - player_target.barrier, 0, amount)
	player_target.barrier = clamp(player_target.barrier - amount, 0, player_target.barrier)
	player_target.health = clamp(player_target.health - pierced, 0, player_target.health)
	if player_target.health <= 0:
		get_parent().end_fight("died")

func player_take_healing(amount):
	player.health = clamp(player.health + amount, 0, player.max_health)

func player_take_mana(amount):
	player.mana = clamp(player.mana + amount, 0, player.max_mana)

func start_turn():
	take_condition_damage(player)
	refresh_data()
	if check_conditions(player, "strike"):
		player_attack_enemy([enemy_list[target_enemy]], player.damage*3)
	if check_conditions(player, "stun"):
		end_turn()
	else:
		$HUD.start_main(player)

func end_turn():
	for i in range(player.conditions.size()-1, -1, -1):
		var condition = player.conditions[i]
		condition.duration -= 1
		if condition.duration <= 0:
			remove_condition(condition)
	turn_manager()

func enemy_turn(enemy):
	if enemy.alive:
		await get_tree().create_timer(0.5).timeout
		if take_condition_damage(enemy):
			turn_manager()
			return
		
		if not check_conditions(enemy, "stun"):
			enemy.turn()
			
		for i in range(enemy.conditions.size()-1, -1, -1):
			var condition = enemy.conditions[i]
			condition.duration -= 1
			if condition.duration <= 0:
				remove_condition(condition)
	turn_manager()

func refresh_data():
	$HUD.get_node("PlayerHealth").text = "Health: " + str(player.health)
	$HUD.get_node("PlayerMana").text = "Mana: " + str(player.mana)
	$HUD.get_node("PlayerBarrier").text = "Barrier: " + str(player.barrier)
	$HUD.get_node("Gold").text = "Gold: " + str(player.gold)
	refresh_target()

func refresh_target():
	if enemy_list.size() > 0:
		for enemy in enemy_list:
			$HUD.get_node("EnemyHP" + str(enemy.health_bar)).value = enemy_percent_health(enemy)
			$HUD.get_node("EnemyHealth" + str(enemy.health_bar)).text = str(enemy.health, "/", enemy.max_health)

func enemy_percent_health(enemy):
	return (float(enemy.health)/float(enemy.max_health)) * 100
