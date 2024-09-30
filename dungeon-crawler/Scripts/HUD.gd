extends CanvasLayer

var player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_retreat_pressed() -> void:
	get_parent().retreat()

func start_main(p):
	player = p
	for i in range(3):
		set_button("Main", "Skills"+str(i+1), player.skills_main[i])
	for i in range(9):
		set_button("Skills"+str(i/3+1), "Skill"+str(i/3+1)+str(i%3+1), player.skills[i])
	show_main()

func set_button(folder, header, new_name):
	get_node(folder).get_node(header).text = new_name.capitalize()

func check_enabled(num) -> bool:
	if player.skills[num] != "":
		var skill = Callable(get_parent(), player.skills[num] + "_enabled")
		return skill.call()
	return false

func activate_skill(num):
	var skill = Callable(get_parent(), player.skills[num])
	skill.call()

func show_main():
	$Main.show()

func hide_main():
	$Main.hide()

func show_skills1():
	$Skills1/Skill11.set_disabled(not check_enabled(0))
	$Skills1/Skill12.set_disabled(not check_enabled(1))
	$Skills1/Skill13.set_disabled(not check_enabled(2))
	$Skills1.show()

func hide_skills1():
	$Skills1.hide()

func show_skills2():
	$Skills2/Skill21.set_disabled(not check_enabled(3))
	$Skills2/Skill22.set_disabled(not check_enabled(4))
	$Skills2/Skill23.set_disabled(not check_enabled(5))
	$Skills2.show()

func hide_skills2():
	$Skills2.hide()

func show_skills3():
	$Skills3/Skill31.set_disabled(not check_enabled(6))
	$Skills3/Skill32.set_disabled(not check_enabled(7))
	$Skills3/Skill33.set_disabled(not check_enabled(8))
	$Skills3.show()

func hide_skills3():
	$Skills3.hide()


func _on_back_1_pressed() -> void:
	hide_skills1()
	show_main()

func _on_back_2_pressed() -> void:
	hide_skills2()
	show_main()

func _on_back_3_pressed() -> void:
	hide_skills3()
	show_main()

func _on_skills_1_pressed() -> void:
	hide_main()
	show_skills1()

func _on_skills_2_pressed() -> void:
	hide_main()
	show_skills2()

func _on_skills_3_pressed() -> void:
	hide_main()
	show_skills3()


func _on_skill_11_pressed() -> void:
	activate_skill(0)
	hide_skills1()

func _on_skill_12_pressed() -> void:
	activate_skill(1)
	hide_skills1()

func _on_skill_13_pressed() -> void:
	activate_skill(2)
	hide_skills1()

func _on_skill_21_pressed() -> void:
	activate_skill(3)
	hide_skills2()

func _on_skill_22_pressed() -> void:
	activate_skill(4)
	hide_skills2()

func _on_skill_23_pressed() -> void:
	activate_skill(5)
	hide_skills2()

func _on_skill_31_pressed() -> void:
	activate_skill(6)
	hide_skills3()
	show_main()

func _on_skill_32_pressed() -> void:
	activate_skill(7)
	hide_skills3()
	show_main()

func _on_skill_33_pressed() -> void:
	activate_skill(8)
	hide_skills3()
	show_main()
