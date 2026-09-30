extends Node2D

var tile_size := 360
var move_speed := 1000
var moving := false


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("move_up"):
		move(Vector2.UP)

	if event.is_action_pressed("move_down"):
		move(Vector2.DOWN)

	if event.is_action_pressed("move_left"):
		move(Vector2.LEFT)

	if event.is_action_pressed("move_right"):
		move(Vector2.RIGHT)
		
func move(direction: Vector2):
	if moving:
		return
	
	moving = true
	
	var destination = position + direction * tile_size
	var duration = tile_size * 2 / move_speed

	var tween = create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(self, "position", destination, duration)

	await tween.finished
	moving = false
	
