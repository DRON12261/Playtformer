extends KinematicBody2D

# Баги:
# 1) Проблема с обнулением горизонтальной скорости при столкновении со стенами
# 2) Проблема автотайла наклонных тайлов
# 3) Проблема с регулировкой горизонтальной скорости на наклонной поверхности

onready var animation : AnimatedSprite = get_parent().get_node("Smoothing2D/AnimatedSprite")
onready var jump_timer : Timer = get_node("JumpTimer")
onready var low_jump_timer : Timer = get_node("LowJumpTimer")
onready var footstepTimer : Timer = get_node("FootstepTimer")
onready var footstepAudio : AudioStreamPlayer2D = get_node("Footstep")
onready var fallOnGroundAudio : AudioStreamPlayer2D = get_node("FallOnGround")

var SPEED : float = 500
var FRICTION : float = 1
var FRICTION_AIR : float = 0.6
var GRAVITY : float = 1500
var JMP_SPEED : float = -500
var VELOCITY : Vector2 = Vector2.ZERO
var MAX_VELOCITY : Vector2 = Vector2(1200, 4000)
var HIGH_SPEED : float = 800
var JUMPING : bool = false
var AIR : bool = false
var AIR_PROC : bool = false
var DeadZone : float = 0.0

var spawn_pos : Vector2 = Vector2(-13170, -2000)

var anim_speed : float = 1
var anim_flip : bool = false
var anim_name : String = "Idle"

func _ready():
	pass

func _physics_process(delta):
	
	if !is_on_floor():
		VELOCITY.y += GRAVITY * delta
		AIR = true
	else:
		if JUMPING:
			JUMPING = false
			
		VELOCITY.y = 20
		jump_timer.stop()
	
	if is_on_ceiling():
		jump_timer.stop()
		low_jump_timer.stop()
		VELOCITY.y = 20
	#print(Input.get_action_strength("run_right"))
	if Input.is_action_pressed("run_left") and abs(Input.get_action_strength("run_left")) > DeadZone:
		if VELOCITY.x > 0:
			VELOCITY.x -= delta * SPEED * 4
		else:
			VELOCITY.x -= delta * SPEED
	elif Input.is_action_pressed("run_right") and abs(Input.get_action_strength("run_right")) > DeadZone:
		if VELOCITY.x < 0:
			VELOCITY.x += delta * SPEED * 4
		else:
			VELOCITY.x += delta * SPEED
	else:
		if !is_on_floor():
			VELOCITY.x = lerp(VELOCITY.x, 0, delta * FRICTION_AIR)
		else:
			VELOCITY.x = lerp(VELOCITY.x, 0, delta * FRICTION)
	
#	var dir = 0
#	if Input.is_action_pressed("run_right"):
#		dir += 1
#	if Input.is_action_pressed("run_left"):
#		dir -= 1
#	if dir != 0:
#		VELOCITY.x = lerp(VELOCITY.x, dir * SPEED, ACC)
#	else:
#		if !is_on_floor():
#			VELOCITY.x = lerp(VELOCITY.x, 0, FRICTION_AIR)
#		else:
#			VELOCITY.x = lerp(VELOCITY.x, 0, FRICTION)
	
	if Input.is_action_pressed("jump") and is_on_floor():
		jump_timer.start()
		low_jump_timer.start()
		JUMPING = true
		Input.start_joy_vibration(0, 0.4, 0.4, 0.2)
		#VELOCITY.y = JMP_SPEED
#		if VELOCITY.x > 0:
#			VELOCITY.x += 100
#		elif VELOCITY.x < 0:
#			VELOCITY.x -= 100
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		#VELOCITY.y = JMP_SPEED
		pass
	if Input.is_action_just_released("jump"):
		jump_timer.stop()
		low_jump_timer.stop()
	
	if !low_jump_timer.is_stopped():
		VELOCITY.y = JMP_SPEED * 0.8
	elif !jump_timer.is_stopped():
		var jump_speed = jump_timer.time_left * 3
		if jump_speed > 1: 
			jump_speed = 1
		VELOCITY.y = JMP_SPEED * jump_speed
	
	if VELOCITY.x > MAX_VELOCITY.x:
		VELOCITY.x = MAX_VELOCITY.x
	if VELOCITY.x < -MAX_VELOCITY.x:
		VELOCITY.x = -MAX_VELOCITY.x
	if VELOCITY.y > MAX_VELOCITY.y:
		VELOCITY.y = MAX_VELOCITY.y
	if VELOCITY.y < -MAX_VELOCITY.y:
		VELOCITY.y = -MAX_VELOCITY.y

	if is_on_wall():
		VELOCITY.x = 0
	
	if VELOCITY.x > 0 and VELOCITY.x < 80 and !Input.is_action_pressed("run_right"):
		VELOCITY.x = 0
	if VELOCITY.x < 0 and VELOCITY.x > -80 and !Input.is_action_pressed("run_left"):
		VELOCITY.x = 0
	
	#print_debug(VELOCITY)
	
	if VELOCITY.y == 20 and abs(VELOCITY.x) > MAX_VELOCITY.x/4:
		var v_x = (abs(VELOCITY.x) - MAX_VELOCITY.x/4) / MAX_VELOCITY.x/3
		#print(v_x)
		if v_x > 1:
			v_x = 1
		Input.start_joy_vibration(0, v_x, v_x, 0.1)
	
	if JUMPING or VELOCITY.x == 0:
		move_and_slide(VELOCITY, Vector2.UP, true, 10, deg2rad(50))
	else:
		move_and_slide_with_snap(VELOCITY, Vector2(0, 30), Vector2.UP, true, 10, deg2rad(50))

func _process(delta):
	if AIR and is_on_floor():
		AIR = false
		Input.start_joy_vibration(0, 0.35, 0.35, 0.2)
		fallOnGroundAudio.volume_db = (-1/(VELOCITY.y+1 / MAX_VELOCITY.y))*10000 + 15
		if fallOnGroundAudio.volume_db < -70:
			fallOnGroundAudio.volume_db = -70
		elif fallOnGroundAudio.volume_db > 30:
			fallOnGroundAudio.volume_db = 30
		print(VELOCITY.y, " ", fallOnGroundAudio.volume_db)
		fallOnGroundAudio.play()		
	if !is_on_floor() and VELOCITY.y < 0:
		anim_speed = 1
		if VELOCITY.x > 0:
			anim_flip = false
		elif VELOCITY.x < 0:
			anim_flip = true
		anim_name = "Jump"
	elif !is_on_floor() and VELOCITY.y >= 0:
		anim_speed = 1
		if VELOCITY.x > 0:
			anim_flip = false
		elif VELOCITY.x < 0:
			anim_flip = true
		anim_name = "Fall"
	elif Input.is_action_pressed("run_left") and VELOCITY.x > 0:
		anim_speed = 1
		anim_flip = false
		anim_name = "Brake"
	elif Input.is_action_pressed("run_right") and VELOCITY.x < 0:
		anim_speed = 1
		anim_flip = true
		anim_name = "Brake"
	elif VELOCITY.x < -25:
		if VELOCITY.x < -HIGH_SPEED:
			anim_speed = -VELOCITY.x / HIGH_SPEED
			anim_flip = true
			anim_name = "Fast Run"
		else:
			anim_speed = -VELOCITY.x / (HIGH_SPEED / 2)
			anim_flip = true
			anim_name = "Run"
	elif VELOCITY.x > 25:
		if VELOCITY.x > HIGH_SPEED:
			anim_speed = VELOCITY.x / HIGH_SPEED
			anim_flip = false
			anim_name = "Fast Run"
		else:
			anim_speed = VELOCITY.x / (HIGH_SPEED / 2)
			anim_flip = false
			anim_name = "Run"
	elif is_on_wall():
		anim_speed = 1
		anim_name = "Idle"
	else:
		anim_speed = 1
		anim_name = "Idle"
	
	animation.speed_scale = anim_speed
	animation.flip_h = anim_flip
	animation.play(anim_name)
	
	footstepAudio.volume_db = -0.6*20 + 5
	match(anim_name):
		"Run":
			var timerW = 1/(anim_speed*4)
			if timerW < 0.25:
				timerW = 0.25
			elif timerW > 0.6:
				timerW = 0.6
			#print(anim_speed, " ", timerW)
			footstepTimer.wait_time = timerW
			footstepAudio.pitch_scale = rand_range(0.9, 1.1)
			footstepAudio.volume_db = -timerW*20 + 5
			if footstepTimer.is_stopped():
				footstepAudio.play()
				footstepTimer.start()
		"Fast Run":
			var timerW = 1/(anim_speed*5)
			if timerW < 0.1:
				timerW = 0.1
			elif timerW > 0.6:
				timerW = 0.6
			#print(anim_speed, " ", timerW)
			footstepTimer.wait_time = timerW
			footstepAudio.pitch_scale = rand_range(0.9, 1.1)
			footstepAudio.volume_db = -timerW*20 + 8
			if footstepTimer.is_stopped():
				footstepAudio.play()
				footstepTimer.start()
	
	if Input.is_action_just_pressed("Quit"):
		get_tree().change_scene("res://objects/MainMenu.tscn")
	
	if Input.is_action_just_pressed("respawn"):
		VELOCITY = Vector2.ZERO
		global_position = spawn_pos
