extends AnimationPlayer

@export var animation_to_play_as_string: String = "move"
@export var re_sync_interval: float = 1.0

var re_sync_timer: Timer
var animation_to_play: Animation
var loop_mode: Animation.LoopMode = Animation.LOOP_NONE
var server_animation_offset: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	animation_to_play = get_animation(animation_to_play_as_string)
	loop_mode = animation_to_play.loop_mode
	if multiplayer.is_server():
		play(animation_to_play_as_string)
	else:
		re_sync_timer = Timer.new()
		re_sync_timer.wait_time = re_sync_interval
		add_child(re_sync_timer)
		re_sync_timer.start()
		re_sync_timer.timeout.connect(_on_re_sync_timer_timeout)
		
		sync_animation_to_server()

func _on_re_sync_timer_timeout():
	sync_animation_to_server()

func sync_animation_to_server():
	get_server_animation_offset.rpc_id(1, multiplayer.get_unique_id())

func _on_client_animation_ended(anim_name: String):
	# make it start from the beginning instead from the offset
	animation_finished.disconnect(_on_client_animation_ended)
	animation_to_play.loop_mode = loop_mode
	play(animation_to_play_as_string)

func play_offsetted_animation() -> void:
	if loop_mode != Animation.LOOP_NONE:
		animation_to_play.loop_mode = Animation.LOOP_NONE
	play_section(animation_to_play_as_string, server_animation_offset)
	if loop_mode != Animation.LOOP_NONE:
		if not animation_finished.is_connected(_on_client_animation_ended):
			animation_finished.connect(_on_client_animation_ended)

@rpc("any_peer", "call_local", "reliable")
func get_server_animation_offset(calling_id: int) -> void:
	return_server_animation_offset.rpc_id(calling_id,current_animation_position)
	
@rpc("any_peer", "call_local", "reliable")
func return_server_animation_offset(animation_offset: float) -> void:
	server_animation_offset = animation_offset
	play_offsetted_animation()
