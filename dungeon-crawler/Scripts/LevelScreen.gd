extends CanvasLayer

var player
var level

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#if level % 5 == 3:
		#$Skills.show()
	#elif level % 5 == 0:
		#$Traits.show()
	#else:
		disable_stats()
		$Stats.show()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func disable_stats():
	$Stats/Endurance.set_disabled(player.endurance >= 16)
	$Stats/Strength.set_disabled(player.strength >= 16)
	$Stats/Magic.set_disabled(player.magic >= 16)
	$Stats/Agility.set_disabled(player.agility >= 16)

func _on_endurance_pressed() -> void:
	player.gain_endurance()
	disable_stats()
	get_parent().leveled_up()

func _on_strength_pressed() -> void:
	player.gain_strength()
	disable_stats()
	get_parent().leveled_up()

func _on_magic_pressed() -> void:
	player.gain_magic()
	disable_stats()
	get_parent().leveled_up()

func _on_agility_pressed() -> void:
	player.gain_agility()
	disable_stats()
	get_parent().leveled_up()


func _on_skill_1_pressed() -> void:
	player.gain_skill()
	get_parent().leveled_up()


func _on_trait_1_pressed() -> void:
	player.gain_trait()
	get_parent().leveled_up()
