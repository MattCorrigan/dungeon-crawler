extends CanvasLayer

var player
var current_event

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_event.player = player
	$Message.text = current_event.message
	$Choice1.text = current_event.choice1
	$Choice2.text = current_event.choice2


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_choice_1_pressed() -> void:
	current_event.choose_1()
	clean_up()


func _on_choice_2_pressed() -> void:
	current_event.choose_2()
	clean_up()


func clean_up():
	current_event.queue_free()
	get_parent().event_screen_off()
