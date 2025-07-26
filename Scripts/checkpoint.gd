extends Area2D

@export var next_mechanic: String= ""
var activated: bool = false

func _on_body_entered(body: Node2D) -> void:
	if activated or not body is Player: return
	var player: Player = body
	if not player.is_multiplayer_authority(): return
	
	activated = true
	player.respawn_position = global_position + Vector2(0, -100)
	modulate = Color.GREEN
	if next_mechanic.replace(" ", "") != "":
		Global.mechanics.append(next_mechanic)
