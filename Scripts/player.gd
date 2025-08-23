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
var respawn_position: Vector2

var extra_jumps: int = 0
var jumps_left: int

var can_start_coyote_timer: bool = false

func _ready() -> void:
	set_multiplayer_authority(int(str(name)))
	
	if not is_multiplayer_authority(): 
		%AnimationPlayer.play("RESET")
		return
	modulate = Global.player_color
	%Camera2D.enabled = true
	global_position = Vector2(randf_range(0, 1138), -50)
	respawn_position = Vector2(1100, -50)
	username = Global.username
	jumps_left = extra_jumps
	Global.mechanic_added.connect(on_mechanic_added)
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
		global_position = respawn_position
	
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
		if can_start_coyote_timer and %CoyoteTimer.is_stopped():
			%CoyoteTimer.start()
	else:
		jumps_left = extra_jumps
		can_start_coyote_timer = true
		if not %CoyoteTimer.is_stopped():
			%CoyoteTimer.stop()

	# Handle jump.
	if not Global.game_chat.is_open:
		if Input.is_action_pressed("jump") and is_on_floor() and not %JumpBufferTimer.is_stopped(): # Jump buffering
			velocity.y = JUMP_VELOCITY
			%JumpBufferTimer.stop()
		
		if Input.is_action_just_pressed("jump"):
			if is_on_floor() or not %CoyoteTimer.is_stopped():
				velocity.y = JUMP_VELOCITY
				
				can_start_coyote_timer = false
				if not %CoyoteTimer.is_stopped():
					%CoyoteTimer.stop()
			elif not is_on_floor() and jumps_left > 0: # extra jumps like double jump
				velocity.y = JUMP_VELOCITY
				%AirJumpEffectParticle.restart()
				%AirJumpEffectParticle.emitting = true
				%AnimationPlayer.play("air_jump")
				%AnimationPlayer.seek(0, true)
				jumps_left -= 1
			else: # Start jump buffer
				if %JumpBufferTimer.is_stopped():
					%JumpBufferTimer.start()
				

	# Get the input direction and handle the movement/deceleration.
	var direction: float = Input.get_axis("move_left", "move_right")
	if Global.game_chat.is_open: direction = 0.0
	
	if direction:
		velocity.x = direction * SPEED
		#if not tween == null and tween.is_running(): tween.stop()
		if not (%AnimationPlayer.current_animation in ["move", "air_jump"]):
			tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
			tween.tween_property(%Sprite2D, "scale:y", 1, 0.1)
			%AnimationPlayer.play("idle")
			if direction > 0:
				%AnimationPlayer.play("move")
			else:
				%AnimationPlayer.play_backwards("move")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if %AnimationPlayer.current_animation in ["move", ""]:
			tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
			tween.tween_property(%Sprite2D, "rotation_degrees", 0, 0.3)
			%AnimationPlayer.play("idle")
	
	if fly_hack:
		velocity = Input.get_vector("move_left", "move_right", "fly_up", "fly_down") * (SPEED * 2)
	
	move_and_slide()

func on_mechanic_added(mechanic: String):
	if mechanic == "double_jump":
		extra_jumps = 1
		jumps_left = extra_jumps


func _on_coyote_timer_timeout() -> void:
	can_start_coyote_timer = false
