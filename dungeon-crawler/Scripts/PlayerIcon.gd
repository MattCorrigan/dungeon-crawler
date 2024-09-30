extends Node2D

var grid = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if grid != null:
		if grid.is_visible_in_tree() and not grid.player_moving:
			var player_location = grid.player_location
			if Input.is_action_just_pressed("up"):
				grid.move_player(Vector2(player_location.x, player_location.y-1))
			elif Input.is_action_just_pressed("down"):
				grid.move_player(Vector2(player_location.x, player_location.y+1))
			elif Input.is_action_just_pressed("left"):
				grid.move_player(Vector2(player_location.x-1, player_location.y))
			elif Input.is_action_just_pressed("right"):
				grid.move_player(Vector2(player_location.x+1, player_location.y))
