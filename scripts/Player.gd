extends KinematicBody2D

# Godot 3.3
# Баги и цели:
# -1) Проблема с обнулением горизонтальной скорости при столкновении со стенами
# -2) Проблема автотайла наклонных тайлов
# -3) Проблема с регулировкой горизонтальной скорости на наклонной поверхности
# -4) Персонаж цепляется за наклонные потолки
# ?5) Дополнительное ускорение на спуске по склону
# -6) Двойной прыжок
# -7) Дэш
# 8) Прыжки от стен
# ?9) Автоподъем на один тайл выше

onready var animation : AnimatedSprite = get_parent().get_node("Smoothing2D/Full")
onready var bodyAnim : AnimatedSprite = get_parent().get_node("Smoothing2D/Body")
onready var leftLegAnim : AnimatedSprite = get_parent().get_node("Smoothing2D/LeftLeg")
onready var rightLegAnim : AnimatedSprite = get_parent().get_node("Smoothing2D/RightLeg")
onready var leftArmAnim : AnimatedSprite = get_parent().get_node("Smoothing2D/LeftArm")
onready var rightArmAnim : AnimatedSprite = get_parent().get_node("Smoothing2D/RightArm")
onready var weaponsAnim : AnimatedSprite = get_parent().get_node("Smoothing2D/WeaponArm")

onready var CrosshairLinePivot : Position2D = get_parent().get_node("Smoothing2D/CrosshairLinePivot")
onready var CrosshairLine : Line2D = get_parent().get_node("Smoothing2D/CrosshairLinePivot/CrosshairLine")
onready var Crosshair : Sprite = get_parent().get_node("Smoothing2D/CrosshairLinePivot/Crosshair")

onready var MainCamera : Camera2D = get_parent().get_node("Smoothing2D/Camera2D")
onready var jump_timer : Timer = get_node("JumpTimer")
onready var low_jump_timer : Timer = get_node("LowJumpTimer")
onready var footstepTimer : Timer = get_node("FootstepTimer")
onready var footstepAudio : AudioStreamPlayer2D = get_node("Footstep")
onready var fallOnGroundAudio : AudioStreamPlayer2D = get_node("FallOnGround")
onready var groundCheckerRay : RayCast2D = get_node("GroundChecker")
onready var dashDirTimer : Timer = get_node("DashDirTimer")
onready var weaponWheelTimer : Timer = get_node("WeaponWheelTimer")
onready var LevelMus : AudioStreamPlayer = get_node("Music")
onready var dashLine : Line2D = get_parent().get_node("Smoothing2D/DashLine")
onready var weaponLine : Line2D = get_parent().get_node("Smoothing2D/Camera2D/HUDCanvas/HUD/WEAPONWH/WeaponLine")
onready var dashTimer : Timer = get_node("DashTimer")

onready var hpHUD : Label = get_parent().get_node("Smoothing2D/Camera2D/HUDCanvas/HUD/HP&ARMOR/Hp")
onready var armorHUD : Label = get_parent().get_node("Smoothing2D/Camera2D/HUDCanvas/HUD/HP&ARMOR/Armor")
onready var timerHUD : Label = get_parent().get_node("Smoothing2D/Camera2D/HUDCanvas/HUD/TIMER/Timer")
onready var killsHUD : Label = get_parent().get_node("Smoothing2D/Camera2D/HUDCanvas/HUD/LEVELINFO/Kills")
onready var secretsHUD : Label = get_parent().get_node("Smoothing2D/Camera2D/HUDCanvas/HUD/LEVELINFO/Secrets")
onready var ammoHUD : Label = get_parent().get_node("Smoothing2D/Camera2D/HUDCanvas/HUD/AMMO/Ammo")
onready var ammoPicHUD : TextureRect = get_parent().get_node("Smoothing2D/Camera2D/HUDCanvas/HUD/AMMO/AmmoPic")
onready var weaponWhHUD : TextureRect = get_parent().get_node("Smoothing2D/Camera2D/HUDCanvas/HUD/WEAPONWH")

onready var ammoLightHUD : Light2D = get_parent().get_node("Smoothing2D/Camera2D/HUDCanvas/HUD/AMMO/AmmoLight")
onready var hpLightHUD : Light2D = get_parent().get_node("Smoothing2D/Camera2D/HUDCanvas/HUD/HP&ARMOR/HpLight")
onready var armorLightHUD : Light2D = get_parent().get_node("Smoothing2D/Camera2D/HUDCanvas/HUD/HP&ARMOR/ArmorLight")
onready var killsLightHUD : Light2D = get_parent().get_node("Smoothing2D/Camera2D/HUDCanvas/HUD/LEVELINFO/KillsLight")
onready var secretsLightHUD : Light2D = get_parent().get_node("Smoothing2D/Camera2D/HUDCanvas/HUD/LEVELINFO/SecretsLight")
onready var timerLightHUD : Light2D = get_parent().get_node("Smoothing2D/Camera2D/HUDCanvas/HUD/TIMER/TimerLight")


onready var weapon1AmmoHUD : Label = get_parent().get_node("Smoothing2D/Camera2D/HUDCanvas/HUD/WEAPONWH/Ammo1")
onready var weapon2AmmoHUD : Label = get_parent().get_node("Smoothing2D/Camera2D/HUDCanvas/HUD/WEAPONWH/Ammo2")
onready var weapon3AmmoHUD : Label = get_parent().get_node("Smoothing2D/Camera2D/HUDCanvas/HUD/WEAPONWH/Ammo3")
onready var weapon4AmmoHUD : Label = get_parent().get_node("Smoothing2D/Camera2D/HUDCanvas/HUD/WEAPONWH/Ammo4")
onready var weapon5AmmoHUD : Label = get_parent().get_node("Smoothing2D/Camera2D/HUDCanvas/HUD/WEAPONWH/Ammo5")
onready var weapon6AmmoHUD : Label = get_parent().get_node("Smoothing2D/Camera2D/HUDCanvas/HUD/WEAPONWH/Ammo6")
onready var weapon7AmmoHUD : Label = get_parent().get_node("Smoothing2D/Camera2D/HUDCanvas/HUD/WEAPONWH/Ammo7")
onready var weapon8AmmoHUD : Label = get_parent().get_node("Smoothing2D/Camera2D/HUDCanvas/HUD/WEAPONWH/Ammo8")
onready var weapon1HUD : Label = get_parent().get_node("Smoothing2D/Camera2D/HUDCanvas/HUD/WEAPONWH/1")
onready var weapon2HUD : Label = get_parent().get_node("Smoothing2D/Camera2D/HUDCanvas/HUD/WEAPONWH/2")
onready var weapon3HUD : Label = get_parent().get_node("Smoothing2D/Camera2D/HUDCanvas/HUD/WEAPONWH/3")
onready var weapon4HUD : Label = get_parent().get_node("Smoothing2D/Camera2D/HUDCanvas/HUD/WEAPONWH/4")
onready var weapon5HUD : Label = get_parent().get_node("Smoothing2D/Camera2D/HUDCanvas/HUD/WEAPONWH/5")
onready var weapon6HUD : Label = get_parent().get_node("Smoothing2D/Camera2D/HUDCanvas/HUD/WEAPONWH/6")
onready var weapon7HUD : Label = get_parent().get_node("Smoothing2D/Camera2D/HUDCanvas/HUD/WEAPONWH/7")
onready var weapon8HUD : Label = get_parent().get_node("Smoothing2D/Camera2D/HUDCanvas/HUD/WEAPONWH/8")
onready var weapon1LightHUD : Light2D = get_parent().get_node("Smoothing2D/Camera2D/HUDCanvas/HUD/WEAPONWH/Light1")
onready var weapon2LightHUD : Light2D = get_parent().get_node("Smoothing2D/Camera2D/HUDCanvas/HUD/WEAPONWH/Light2")
onready var weapon3LightHUD : Light2D = get_parent().get_node("Smoothing2D/Camera2D/HUDCanvas/HUD/WEAPONWH/Light3")
onready var weapon4LightHUD : Light2D = get_parent().get_node("Smoothing2D/Camera2D/HUDCanvas/HUD/WEAPONWH/Light4")
onready var weapon5LightHUD : Light2D = get_parent().get_node("Smoothing2D/Camera2D/HUDCanvas/HUD/WEAPONWH/Light5")
onready var weapon6LightHUD : Light2D = get_parent().get_node("Smoothing2D/Camera2D/HUDCanvas/HUD/WEAPONWH/Light6")
onready var weapon7LightHUD : Light2D = get_parent().get_node("Smoothing2D/Camera2D/HUDCanvas/HUD/WEAPONWH/Light7")
onready var weapon8LightHUD : Light2D = get_parent().get_node("Smoothing2D/Camera2D/HUDCanvas/HUD/WEAPONWH/Light8")
onready var weapon1PicHUD : TextureRect = get_parent().get_node("Smoothing2D/Camera2D/HUDCanvas/HUD/WEAPONWH/Pic1")
onready var weapon2PicHUD : TextureRect = get_parent().get_node("Smoothing2D/Camera2D/HUDCanvas/HUD/WEAPONWH/Pic2")
onready var weapon3PicHUD : TextureRect = get_parent().get_node("Smoothing2D/Camera2D/HUDCanvas/HUD/WEAPONWH/Pic3")
onready var weapon4PicHUD : TextureRect = get_parent().get_node("Smoothing2D/Camera2D/HUDCanvas/HUD/WEAPONWH/Pic4")
onready var weapon5PicHUD : TextureRect = get_parent().get_node("Smoothing2D/Camera2D/HUDCanvas/HUD/WEAPONWH/Pic5")
onready var weapon6PicHUD : TextureRect = get_parent().get_node("Smoothing2D/Camera2D/HUDCanvas/HUD/WEAPONWH/Pic6")
onready var weapon7PicHUD : TextureRect = get_parent().get_node("Smoothing2D/Camera2D/HUDCanvas/HUD/WEAPONWH/Pic7")
onready var weapon8PicHUD : TextureRect = get_parent().get_node("Smoothing2D/Camera2D/HUDCanvas/HUD/WEAPONWH/Pic8")

onready var weaponAmmoHUDs : Array = [weapon1AmmoHUD, weapon2AmmoHUD, weapon3AmmoHUD, weapon4AmmoHUD, weapon5AmmoHUD, weapon6AmmoHUD, weapon7AmmoHUD, weapon8AmmoHUD]
onready var weaponNumHUDs : Array = [weapon1HUD, weapon2HUD, weapon3HUD, weapon4HUD, weapon5HUD, weapon6HUD, weapon7HUD, weapon8HUD]
onready var weaponLightHUDs : Array = [weapon1LightHUD, weapon2LightHUD, weapon3LightHUD, weapon4LightHUD, weapon5LightHUD, weapon6LightHUD, weapon7LightHUD, weapon8LightHUD]
onready var weaponPicHUDs : Array = [weapon1PicHUD, weapon2PicHUD, weapon3PicHUD, weapon4PicHUD, weapon5PicHUD, weapon6PicHUD, weapon7PicHUD, weapon8PicHUD]

var FullColor : Color = Color("#ffffff")
var GoodColor : Color = Color("#00ff15")
var MediumColor : Color = Color("#9dff00")
var BadColor : Color = Color("#ff0000")

var SPEED : float = 500
var FRICTION : float = 1
var FRICTION_AIR : float = 0.6
var GRAVITY : float = 1500
var JMP_SPEED : float = -500
var VELOCITY : Vector2 = Vector2.ZERO
var MAX_VELOCITY : Vector2 = Vector2(1200, 4000)
var HIGH_SPEED : float = 800
var JUMPING : int = 0
var MAX_JUMPS : int = 2
var AIR : bool = false
var AIR_PROC : bool = false
var DASHING : int = 0
var MAX_DASHES : int = 2
var IS_DASHING : bool = false
var STOP_DASHING : bool = false
var DeadZone : float = 0.0
var justCollide : bool = false
var OldVELOCITY : Vector2 = Vector2.ZERO
var preSelectedWeapon : int = 1
var SelectedWeapon : int = 1
var Health : int = 98
var MaxHealth : int = 200
var Armor : int = 20
var MaxArmor : int = 200
var isAlive : bool = true
var cameraSmoothSpeed : float = 4
var weaponsAnimIdleOffsetX : float = 0

var lookDeadzone : float = 0.7
var lookAngle : float = 0
var lookflip : bool = false
var isAiming : bool = false

var weaponsMaxAmmo = [1, 50, 200, 50, 30, 100, 3, 100]
var weaponsAmmo = [1 , 20, 150, 0, 10, 45, 2, 100]
var weaponsUnlock = [true, true, true, true, true, true, true, true]

var slope_normal_angle = 0

var spawn_pos : Vector2 = Vector2(-13170, -2000)

var anim_speed : float = 1
var anim_flip : bool = false
var anim_name : String = "Idle"

func selectWeapon(weaponNum : int):
	if (weaponsUnlock[weaponNum - 1]):
			SelectedWeapon = weaponNum
			ammoPicHUD.texture = load("res://sprites/HUD/Weapon" + str(SelectedWeapon) + "AmmoPic.png")
			weaponsAnim.play(str(weaponNum))

func selectWeaponOnWhell(weaponNum : int):
	weaponAmmoHUDs[weaponNum - 1].modulate = Color("#097e00")
	weaponNumHUDs[weaponNum - 1].modulate = Color("#097e00")
	weaponLightHUDs[weaponNum - 1].visible = true
	for n in 8:
		if n != weaponNum - 1:
			weaponAmmoHUDs[n].modulate = Color("#ffffff")
			weaponNumHUDs[n].modulate = Color("#ffffff")
			weaponLightHUDs[n].visible = false

func checkWeaponsUnlock():
	for n in 8:
		weaponAmmoHUDs[n].visible = weaponsUnlock[n]
		weaponNumHUDs[n].visible = weaponsUnlock[n]
		weaponPicHUDs[n].visible = weaponsUnlock[n]

func _ready():
	selectWeaponOnWhell(SelectedWeapon)
	selectWeapon(SelectedWeapon)
	checkWeaponsUnlock()

func _physics_process(delta):
	#print(VELOCITY)
	
	if !is_on_floor():
		VELOCITY.y += GRAVITY * delta
		AIR = true
	else:
		if JUMPING != MAX_JUMPS:
			JUMPING = MAX_JUMPS
		if DASHING != MAX_DASHES:
			DASHING = MAX_DASHES
		VELOCITY.y = 20
		jump_timer.stop()
	
	if is_on_ceiling():
		jump_timer.stop()
		low_jump_timer.stop()
		VELOCITY.y = 20
		if get_slide_count() > 0 and !justCollide:
			var collision : KinematicCollision2D = get_slide_collision(0)
			var normalC = collision.normal
			var angleNormal = rad2deg(normalC.angle()) - 90
			#print(angleNormal, "    ", Vector2(20, 0).rotated(deg2rad(angleNormal) + 90))
			if abs(angleNormal) > 5:
				VELOCITY += Vector2(200, 0).rotated(deg2rad(angleNormal) + 90)
				justCollide = true
	if Input.is_action_pressed("run_left") and abs(Input.get_action_strength("run_left")) > DeadZone and dashTimer.is_stopped():
		if VELOCITY.x > 0:
			VELOCITY.x -= delta * SPEED * 4
		else:
			VELOCITY.x -= delta * SPEED
	elif Input.is_action_pressed("run_right") and abs(Input.get_action_strength("run_right")) > DeadZone and dashTimer.is_stopped():
		if VELOCITY.x < 0:
			VELOCITY.x += delta * SPEED * 4
		else:
			VELOCITY.x += delta * SPEED
	elif dashTimer.is_stopped():
		if !is_on_floor():
			VELOCITY.x = lerp(VELOCITY.x, 0, delta * FRICTION_AIR)
		else:
			VELOCITY.x = lerp(VELOCITY.x, 0, delta * FRICTION)
	
	#if Input.is_action_pressed("jump") and is_on_floor():
		#Input.start_joy_vibration(0, 0.4, 0.4, 0.2)
	
	if Input.is_action_just_pressed("jump") and (JUMPING > 0 or is_on_floor()):
		jump_timer.start()
		low_jump_timer.start()
		JUMPING -= 1
		Input.start_joy_vibration(0, 0.4, 0.4, 0.2)
	if Input.is_action_just_released("jump"):
		jump_timer.stop()
		low_jump_timer.stop()
	
	if (Input.is_action_just_pressed("dash") and DASHING > 0 and dashTimer.is_stopped()) or (Input.is_action_pressed("dash") and DASHING > 0 and STOP_DASHING):
		dashLine.visible = true
		IS_DASHING = true
		if STOP_DASHING:
			STOP_DASHING = false
		dashDirTimer.start()
	
	if Input.is_action_just_released("dash") and IS_DASHING:
		dashLine.visible = false
		low_jump_timer.stop()
		jump_timer.stop()
		DASHING -= 1
		VELOCITY = Vector2(5000, 0).rotated(dashLine.rotation)
		#MainCamera.global_position += VELOCITY
		#print(VELOCITY, "    ", dashLine.rotation_degrees)
		IS_DASHING = false
		dashTimer.start()
		dashDirTimer.stop()
	
	if Input.is_action_just_pressed("weaponWh"):
		weaponWheelTimer.start()
		weaponWhHUD.visible = true
		#weaponLine.visible = true
	
	if Input.is_action_just_released("weaponWh"):
		weaponWheelTimer.stop()
		weaponWhHUD.visible = false
		#weaponLine.visible = false
		selectWeapon(preSelectedWeapon)
	
	if Input.is_action_pressed("dash") and !dashDirTimer.is_stopped():
		Engine.time_scale = (dashDirTimer.wait_time / dashDirTimer.time_left) / dashDirTimer.wait_time
		if dashDirTimer.time_left < 2.0:
			dashLine.visible = false
			dashDirTimer.stop()
			IS_DASHING = false
		var deadzone = 0.5
		var controllerangle = 0
		var xAxisRL = Input.get_joy_axis(0, JOY_AXIS_0)
		var yAxisUD = Input.get_joy_axis(0 ,JOY_AXIS_1)
		if abs(xAxisRL) > deadzone || abs(yAxisUD) > deadzone:
			controllerangle = rad2deg(Vector2(xAxisRL, yAxisUD).angle())
			controllerangle = round(controllerangle/22.5) * 22.5
			dashLine.rotation_degrees = controllerangle
		#print(dashDirTimer.time_left, "    ",dashDirTimer.wait_time, "     ", Engine.time_scale)
	elif Input.is_action_pressed("weaponWh"):
		#print(weaponWheelTimer.time_left, "   ", weaponWheelTimer.is_stopped(), "    ", Engine.time_scale)
		if weaponWheelTimer.time_left != 0:
			Engine.time_scale = (weaponWheelTimer.wait_time / weaponWheelTimer.time_left) / weaponWheelTimer.wait_time
		elif Engine.time_scale < 1:
			Engine.time_scale += 0.1
		elif Engine.time_scale > 1:
			Engine.time_scale = 1
		if weaponWheelTimer.time_left < 2.0:
			weaponWheelTimer.stop()
		var deadzone = 0.5
		var controllerangle = 0
		var xAxisRL = Input.get_joy_axis(0, JOY_AXIS_2)
		var yAxisUD = Input.get_joy_axis(0 ,JOY_AXIS_3)
		if abs(xAxisRL) > deadzone || abs(yAxisUD) > deadzone:
			controllerangle = rad2deg(Vector2(xAxisRL, yAxisUD).angle())
			var oldAngle = controllerangle
			controllerangle = round(controllerangle/22.5)
			if (int(controllerangle) % 2 == 0):
				if oldAngle > controllerangle*22.5:
					controllerangle += 1
				else:
					controllerangle -= 1
			weaponLine.rotation_degrees = controllerangle*22.5
			if controllerangle == -3:
				preSelectedWeapon = 1
			elif controllerangle == -1:
				preSelectedWeapon = 2
			elif controllerangle == 1:
				preSelectedWeapon = 3
			elif controllerangle == 3:
				preSelectedWeapon = 4
			elif controllerangle == 5:
				preSelectedWeapon = 5
			elif controllerangle == 7 or controllerangle == -9:
				preSelectedWeapon = 6
			elif controllerangle == 9 or controllerangle == -7:
				preSelectedWeapon = 7
			elif controllerangle == -5:
				preSelectedWeapon = 8
			selectWeaponOnWhell(preSelectedWeapon)
	elif Engine.time_scale < 1:
		Engine.time_scale += 0.1
	elif Engine.time_scale > 1:
		Engine.time_scale = 1
	
	if !low_jump_timer.is_stopped():
		VELOCITY.y = JMP_SPEED * 0.8
	elif !jump_timer.is_stopped():
		var jump_speed = jump_timer.time_left * 3
		if jump_speed > 1: 
			jump_speed = 1
		VELOCITY.y = JMP_SPEED * jump_speed
	
	if dashTimer.time_left == 0:
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
	
	#print(VELOCITY)
	if is_on_floor() and abs(VELOCITY.x) > MAX_VELOCITY.x/4:
		var v_x = (abs(VELOCITY.x) - MAX_VELOCITY.x/4) / MAX_VELOCITY.x/3
		if v_x > 1:
			v_x = 1
		Input.start_joy_vibration(0, v_x, v_x, 0.1)
		#print(v_x)
	
	if JUMPING != MAX_JUMPS or DASHING != MAX_DASHES or VELOCITY.x == 0:
		#print("AIR")
		var angleNormal = 0;
		if (get_slide_count() > 0):
			var collision : KinematicCollision2D = get_slide_collision(0)
			var normalC = collision.normal
			angleNormal = rad2deg(normalC.angle()) - 90
			#print(get_slide_count(),"   ", angleNormal, "    ", VELOCITY)
			if !is_on_floor() and abs(angleNormal) > 5 and ((VELOCITY.x < 0 and angleNormal < 0) or (VELOCITY.x > 0 and angleNormal > 0)):
				VELOCITY.x = 0
		move_and_slide(VELOCITY, Vector2.UP, true, 10, deg2rad(50))
	else:
		var angleNormal = 0
		if (get_slide_count() > 0):
			var collision : KinematicCollision2D = get_slide_collision(0)
			var normalC = collision.normal
			angleNormal = rad2deg(normalC.angle()) + 90
		var VelocityM = 1 - abs(angleNormal)/1000.0
		VELOCITY.x = VELOCITY.x * VelocityM
		#print("GROUND")
		move_and_slide_with_snap(VELOCITY, Vector2(0, 56), Vector2.UP, true, 10, deg2rad(50))
		#print(angleNormal, "   ", VelocityM, "   -   ", VELOCITY.x, "        ", Vector2.UP.rotated(deg2rad(angleNormal)))

func _process(delta):
	#if Input.is_action_pressed("dash") and !dashDirTimer.is_stopped():
		#Engine.time_scale = (dashDirTimer.wait_time / dashDirTimer.time_left) / dashDirTimer.wait_time
	
	#MainCamera.smoothing_speed = cameraSmoothSpeed * (Engine.time_scale + (1 - Engine.time_scale)/2)
	MainCamera.smoothing_speed = cameraSmoothSpeed * Engine.time_scale
	if LevelMus != null:
		#LevelMus.volume_db = 1/Engine.time_scale * -80
		pass
	
	for n in 8:
		weaponAmmoHUDs[n].text = str(weaponsAmmo[n])
	ammoHUD.text = str(weaponsAmmo[SelectedWeapon - 1])
	hpHUD.text = str(Health)
	armorHUD.text = str(Armor)
	
	if weaponsAmmo[SelectedWeapon - 1] >= weaponsMaxAmmo[SelectedWeapon - 1]:
		ammoLightHUD.energy = 1
		ammoLightHUD.color = FullColor
	elif weaponsAmmo[SelectedWeapon - 1] >= weaponsMaxAmmo[SelectedWeapon - 1]/4*3: 
		ammoLightHUD.energy = 2
		ammoLightHUD.color = GoodColor
	elif weaponsAmmo[SelectedWeapon - 1] >= weaponsMaxAmmo[SelectedWeapon - 1]/4: 
		ammoLightHUD.energy = 2
		ammoLightHUD.color = MediumColor
	else: 
		ammoLightHUD.energy = 2
		ammoLightHUD.color = BadColor
	
	if Health >= MaxHealth:
		hpLightHUD.energy = 1
		hpLightHUD.color = FullColor
	elif Health >= MaxHealth/4*3: 
		hpLightHUD.energy = 2
		hpLightHUD.color = GoodColor
	elif Health >= MaxHealth/4: 
		hpLightHUD.energy = 2
		hpLightHUD.color = MediumColor
	else: 
		hpLightHUD.energy = 2
		hpLightHUD.color = BadColor
	
	if Armor >= MaxArmor:
		armorLightHUD.energy = 1
		armorLightHUD.color = FullColor
	elif Armor >= MaxArmor/4*3: 
		armorLightHUD.energy = 2
		armorLightHUD.color = GoodColor
	elif Armor >= MaxArmor/4: 
		armorLightHUD.energy = 2
		armorLightHUD.color = MediumColor
	else: 
		armorLightHUD.energy = 2
		armorLightHUD.color = BadColor
	
	if AIR and is_on_floor():
		AIR = false
		Input.start_joy_vibration(0, 0.35, 0.35, 0.2)
		fallOnGroundAudio.volume_db = (-1/(VELOCITY.y+1 / MAX_VELOCITY.y))*10000 + 15
		if fallOnGroundAudio.volume_db < -70:
			fallOnGroundAudio.volume_db = -70
		elif fallOnGroundAudio.volume_db > 30:
			fallOnGroundAudio.volume_db = 30
		fallOnGroundAudio.pitch_scale = 1 * Engine.time_scale
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
	
	var xAxRL = Input.get_joy_axis(0, JOY_AXIS_2)
	var yAxUD = Input.get_joy_axis(0 ,JOY_AXIS_3)
	#(abs(xAxRL) > lookDeadzone || abs(yAxUD) > lookDeadzone)
	if Vector2(xAxRL, yAxUD).length() > lookDeadzone  and !Input.is_action_pressed("weaponWh"):
		lookAngle = int(rad2deg(Vector2(xAxRL, yAxUD).angle()))/1*1
		if lookAngle > 90 or lookAngle < -90:
			lookflip = true
		else:
			lookflip = false
		CrosshairLinePivot.rotation_degrees = lookAngle
		isAiming = true
	else:
		if VELOCITY.x == 0:
			anim_flip = lookflip
		else:
			lookflip = anim_flip
		if lookflip:
			lookAngle = 180
			CrosshairLinePivot.rotation_degrees = lookAngle
		else:
			lookAngle = 0
			CrosshairLinePivot.rotation_degrees = lookAngle
		isAiming = false
	weaponsAnim.rotation_degrees = lookAngle if !lookflip else lookAngle - 180
	bodyAnim.rotation_degrees = lookAngle*0.6 if !lookflip else (lookAngle + 180)*0.6 if lookAngle < 0 else (lookAngle - 180)*0.6
	if isAiming:
		var camOffset = Vector2(0.6,0).rotated(deg2rad(lookAngle))
		MainCamera.offset_h = camOffset.x# + (VELOCITY.x / MAX_VELOCITY.x if VELOCITY.x / MAX_VELOCITY.x <= 1 else 1)
		MainCamera.offset_v = camOffset.y*1.4
		weaponsAnim.offset.y = 0
		weaponsAnimIdleOffsetX = 0
	else:
		weaponsAnim.offset.y = 3
		weaponsAnimIdleOffsetX = -2
		weaponsAnim.rotation_degrees = 25 if !lookflip else -25
		MainCamera.offset_h = 0#(VELOCITY.x / MAX_VELOCITY.x if VELOCITY.x / MAX_VELOCITY.x <= 1 else 1)
		MainCamera.offset_v = 0
	
	animation.speed_scale = anim_speed
	animation.flip_h = anim_flip
	animation.play(anim_name)
	bodyAnim.speed_scale = anim_speed
	bodyAnim.flip_h = lookflip
	bodyAnim.play(anim_name)
	leftLegAnim.speed_scale = anim_speed
	leftLegAnim.flip_h = anim_flip
	leftLegAnim.play(anim_name)
	rightLegAnim.speed_scale = anim_speed
	rightLegAnim.flip_h = anim_flip
	rightLegAnim.play(anim_name)
	
	leftArmAnim.speed_scale = anim_speed
	leftArmAnim.flip_h = anim_flip
	leftArmAnim.play(anim_name)
	rightArmAnim.speed_scale = anim_speed
	rightArmAnim.flip_h = anim_flip
	
	rightArmAnim.play(anim_name)
	weaponsAnim.flip_h = lookflip
	weaponsAnim.offset.x = -8-weaponsAnimIdleOffsetX if lookflip else 8+weaponsAnimIdleOffsetX
	
	footstepAudio.volume_db = -0.6*20 + 5
	match(anim_name):
		"Run":
			var timerW = 1/(anim_speed*4)
			if timerW < 0.25:
				timerW = 0.25
			elif timerW > 0.6:
				timerW = 0.6
			footstepTimer.wait_time = timerW
			footstepAudio.pitch_scale = rand_range(0.9, 1.1) * Engine.time_scale
			footstepAudio.volume_db = -timerW*20 + 5
			if footstepTimer.is_stopped():
				footstepAudio.play()
				footstepTimer.start()
				#print(timerW)
		"Fast Run":
			var timerW = 1/(anim_speed*5)
			if timerW < 0.1:
				timerW = 0.1
			elif timerW > 0.6:
				timerW = 0.6
			footstepTimer.wait_time = timerW
			footstepAudio.pitch_scale = rand_range(0.9, 1.1) * Engine.time_scale
			footstepAudio.volume_db = -timerW*20 + 8
			if footstepTimer.is_stopped():
				footstepAudio.play()
				footstepTimer.start()
				#print(timerW)
	
	if Input.is_action_just_pressed("Quit"):
		get_tree().change_scene("res://objects/MainMenu.tscn")
	
	if Input.is_action_just_pressed("respawn"):
		VELOCITY = Vector2.ZERO
		global_position = spawn_pos

func _on_DashTimer_timeout():
	STOP_DASHING = true
	VELOCITY = VELOCITY.normalized()*1000
