class_name Player
extends CharacterBody2D

@export var fly_hack: bool = false

const SPEED = 400.0
const JUMP_VELOCITY = -600.0

var username: String = "NAME"
var tween: Tween
var deaths: int = 0:
	set(value):
		deaths = value
		queue_redraw()

func _ready() -> void:
	set_multiplayer_authority(int(str(name)))
	
	if not is_multiplayer_authority(): 
		%AnimationPlayer.play("RESET")
		return
	modulate = Global.player_color
	%Camera2D.enabled = true
	global_position = Vector2(randf_range(0, 1138), -50)
	username = Global.username
	Global.game_chat.send_message.rpc(username + " joined the game!", Global.player_color)

func _draw() -> void:
	var default_font = ThemeDB.fallback_font
	var width: float = 500
	draw_string(default_font, Vector2(-(width/2), -70), username, HORIZONTAL_ALIGNMENT_CENTER, width)
	draw_string(default_font, Vector2(-(width/2), -90), "Deaths: " + str(deaths), HORIZONTAL_ALIGNMENT_CENTER, width)

func _process(delta: float) -> void:
	if not is_multiplayer_authority(): return
	
	if global_position.y >= 1000:
		deaths += 1
		velocity = Vector2.ZERO
		global_position = Vector2(randf_range(1008, 1300), -50)
	
	if Global.game_chat.is_open: return
	if Input.is_action_just_pressed("randomize_color"):
		Global.player_color = Color.from_hsv(randf_range(0, 1), randf_range(0.8, 1), randf_range(.8, 1))
		modulate = Global.player_color
		SaveSystem.save_data()

func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority(): return
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if not Global.game_chat.is_open and Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var direction: float = Input.get_axis("move_left", "move_right")
	if Global.game_chat.is_open: direction = 0.0
	
	if direction:
		velocity.x = direction * SPEED
		#if not tween == null and tween.is_running(): tween.stop()
		if %AnimationPlayer.current_animation != "move":
			tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
			tween.tween_property(%Sprite2D, "scale:y", 1, 0.1)
			%AnimationPlayer.play("idle")
			if direction > 0:
				%AnimationPlayer.play("move")
			else:
				%AnimationPlayer.play_backwards("move")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if %AnimationPlayer.current_animation == "move":
			tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
			tween.tween_property(%Sprite2D, "rotation_degrees", 0, 0.3)
			%AnimationPlayer.play("idle")
	
	if fly_hack:
		velocity = Input.get_vector("move_left", "move_right", "fly_up", "fly_down") * (SPEED * 2)
	
	move_and_slide()
