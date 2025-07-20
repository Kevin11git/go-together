extends Area2D


var activated: bool = false

func _on_body_entered(body: Node2D) -> void:
	if activated or not body is Player: return
	var player: Player = body
	if not player.is_multiplayer_authority(): return
	
	activated = true
	player.respawn_position = global_position + Vector2(0, -100)
	modulate = Color.GREEN
