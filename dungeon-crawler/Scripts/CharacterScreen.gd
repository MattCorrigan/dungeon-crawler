extends CanvasLayer

var player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var maxed = func (stat):
		if stat >= 16:
			return " (Max)"
		return ""
	
	$Endurance.text = "Endurance: " + str(player.endurance) + maxed.call(player.endurance)
	$Health.text = "Health: " + str(player.health) + "/" + str(player.max_health)
	$Protection.text = "Protection: " + str(int(player.protection*100)) + "%"
	
	$Strength.text = "Strength: " + str(player.strength) + maxed.call(player.strength)
	$Damage.text = "Damage: " + str(player.damage)
	$CritChance.text = "Critical Chance: " + str(int(player.crit_chance*100)) + "%"
	$CritDamage.text = "Critical Damage: +" + str(int(player.crit_damage*100)) + "%"
	
	$Magic.text = "Magic: " + str(player.magic) + maxed.call(player.magic)
	$Mana.text = "Mana: " + str(player.mana) + "/" + str(player.max_mana)
	$SpellDamage.text = "Spell Damage: " + str(player.spell_damage)
	
	$Agility.text = "Agility: " + str(player.agility) + maxed.call(player.agility)
	$Speed.text = "Speed: " + str(player.speed)
	$Evasion.text = "Evasion: " + str(int(player.evasion*100)) + "%"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_back_c_pressed() -> void:
	get_parent().character_screen_off()
