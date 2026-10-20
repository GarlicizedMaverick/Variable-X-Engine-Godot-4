# TODO: Make the Rolling Shield destroy enemy projectiles
class_name BusterRollingShield extends CharacterBody2D


signal health_depleted
signal health_changed(current_health: float, max_health: float)

@onready var muzzle_flash: Sprite2D = $MuzzleFlashSprite
@onready var sprite: Sprite2D = $Sprite
@onready var collider: CollisionShape2D = $Collider
@onready var collider_corner: CollisionShape2D = $ColliderCorner
@onready var hurtbox: HurtBox2D = $HurtBox2D
@onready var screen_notif: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
@onready var ray_wl_top: RayCast2D = $Sensors/RayWallLeftTop
@onready var ray_wl_center: RayCast2D = $Sensors/RayWallLeftCenter
@onready var ray_wl_bottom: RayCast2D = $Sensors/RayWallLeftBottom
@onready var ray_wr_top: RayCast2D = $Sensors/RayWallRightTop
@onready var ray_wr_center: RayCast2D = $Sensors/RayWallRightCenter
@onready var ray_wr_bottom: RayCast2D = $Sensors/RayWallRightBottom
@onready var crush_detector: Area2D = $Sensors/CrushDetector
@onready var uncrush_left: Area2D = $Sensors/UncrushLeft
@onready var uncrush_right: Area2D = $Sensors/UncrushRight
@onready var uncrush_top: Area2D = $Sensors/UncrushTop
@onready var uncrush_bottom: Area2D = $Sensors/UncrushBottom
@onready var flip_v_timer: Timer = $FlipVTimer
@onready var muzzle_flash_timer: Timer = $MuzzleFlashTimer

const BASE_SPEED: int = 480 # SNES accurate (not multiplied by 5/4)
const GRAVITY: int = 1800 # Not affected by water
const TERMINAL_FALL_SPEED: int = 480 # Not affected by water
const NORMAL_INITIAL_RISING_SPEED: int = -240 # Not SNES accurate (there is no initial hop)
const PUNTED_BY_X_RISING_SPEED: int = -720 # DEFINITELY not SNES accurate (there is no punt)
const MAX_HEALTH: int = 16 # The original Rolling Shield only gets one wall bounce and one enemy hit
const INVINCIBILITY_PERIOD_E: float = 0.15 # In seconds
const INVINCIBILITY_PERIOD_W: float = 0.2 # In seconds

var speed: float
var initial_velocity_y: int
var direction: int
var health: int: set = _on_health_set


func _ready()->void:
	hurtbox.damage_taken.connect(_on_damage_taken)
	screen_notif.screen_exited.connect(_on_screen_exited)
	flip_v_timer.timeout.connect(_on_flip_v_timer_timeout)
	muzzle_flash_timer.timeout.connect(_on_muzzle_flash_timer_timeout)
	health_depleted.connect(_on_health_depleted)
	
	muzzle_flash.top_level = true
	muzzle_flash.modulate.a8 = 192
	
	health = MAX_HEALTH
	
	if Input.is_action_pressed("dpad_up"):
		initial_velocity_y = PUNTED_BY_X_RISING_SPEED
	else:
		initial_velocity_y = NORMAL_INITIAL_RISING_SPEED
	
	velocity.y = initial_velocity_y


func _physics_process(delta: float)->void:
	handle_corner()
	handle_crushing()
	handle_gravity(delta)
	handle_hspeed()
	flip_on_wall()
	move_and_slide()
	handle_being_truly_stuck(delta)
	animate()


func _on_health_set(new_value: int)->void:
	health = clampi(new_value, 0, MAX_HEALTH)
	health_changed.emit(health, MAX_HEALTH)
	if health <= 0:
		health_depleted.emit()


func _on_health_depleted()->void:
	queue_free()


func _on_damage_taken(hitbox: HitBox2D)->void:
	var enemy_hp: float = hitbox.get_parent().health
	var enemy_damage: int
	
	match true:
		_ when enemy_hp <= 4:
			enemy_damage = 2
		
		_ when enemy_hp >= 5 and enemy_hp <= 8:
			enemy_damage = 4
		
		_ when enemy_hp >= 9 and enemy_hp <= 12:
			enemy_damage = 6
		
		_ when enemy_hp >= 13:
			enemy_damage = 8
	
	health -= enemy_damage
	hurtbox.set_invincibility_period(INVINCIBILITY_PERIOD_E)


func _on_screen_exited()->void:
	queue_free()


func _on_flip_v_timer_timeout()->void:
	sprite.flip_v = !sprite.flip_v
	muzzle_flash.flip_v = !muzzle_flash.flip_v


func _on_muzzle_flash_timer_timeout()->void:
	var tween: Tween =\
	get_tree().create_tween().set_parallel(false).set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.tween_property(muzzle_flash, "modulate:a", 0, 0.05)


func handle_corner()->void:
	if direction == 1:
		# Bottom left when facing right
		collider_corner.position.x = -15
	else:
		# Bottom right when facing left
		collider_corner.position.x = 15


func handle_crushing()->void:
	if crush_detector.has_overlapping_bodies():
		if uncrush_left.has_overlapping_bodies() and uncrush_right.has_overlapping_bodies()\
		and uncrush_top.has_overlapping_bodies() and uncrush_bottom.has_overlapping_bodies():
			# Completely crushed
			collider.disabled = true
		else:
			collider.disabled = true
			# Horizontal
			if !uncrush_left.has_overlapping_bodies() and !uncrush_right.has_overlapping_bodies():
				# Not detecting to either left or right.
				# Prioritize the opposite side of the current direction.
				position.x -= 2 * direction
			elif !uncrush_left.has_overlapping_bodies():
				# Not detecting to the left, so go left
				direction = -1
				position.x -= 2
			elif !uncrush_right.has_overlapping_bodies():
				# Not detecting to the right, so go right
				direction = 1
				position.x += 2
			
			# Vertical
			if !uncrush_top.has_overlapping_bodies() and !uncrush_bottom.has_overlapping_bodies():
				# Not detecting either above or below.
				# Prioritize going upward
				position.y -= 2
			elif !uncrush_top.has_overlapping_bodies():
				# Not detecting upward, so go up
				position.y -= 2
			elif !uncrush_bottom.has_overlapping_bodies():
				# Not detecting downward, so go down
				position.y += 2
	else:
		collider.disabled = false


func handle_gravity(delta: float)->void:
	velocity.y += GRAVITY * delta
	if velocity.y >= TERMINAL_FALL_SPEED:
		velocity.y = TERMINAL_FALL_SPEED


func handle_hspeed()->void:
	velocity.x = speed * direction


func flip_on_wall()->void:
	const BOUNCE_OFFSET_X: int = 16
	if hitting_left_wall():
		position.x += BOUNCE_OFFSET_X # This makes it so the ball ONLY takes 1 hit when it bounces.
		direction = 1
		
		health -= 2
		hurtbox.set_invincibility_period(INVINCIBILITY_PERIOD_W)
		
	elif hitting_right_wall():
		position.x -= BOUNCE_OFFSET_X # Same as previous comment.
		direction = -1
		
		health -= 2
		hurtbox.set_invincibility_period(INVINCIBILITY_PERIOD_W)
		
	elif hitting_left_wall() and hitting_right_wall():
		direction = direction


func hitting_left_wall()->bool:
	if (ray_wl_top.is_colliding() and ray_wl_top.get_collision_normal() == Vector2.RIGHT)\
	or (ray_wl_center.is_colliding() and ray_wl_center.get_collision_normal() == Vector2.RIGHT)\
	or (ray_wl_bottom.is_colliding() and ray_wl_bottom.get_collision_normal() == Vector2.RIGHT):
		return true
	else:
		return false


func hitting_right_wall()->bool:
	if (ray_wr_top.is_colliding() and ray_wr_top.get_collision_normal() == Vector2.LEFT)\
	or (ray_wr_center.is_colliding() and ray_wr_center.get_collision_normal() == Vector2.LEFT)\
	or (ray_wr_bottom.is_colliding() and ray_wr_bottom.get_collision_normal() == Vector2.LEFT):
		return true
	else:
		return false


func handle_being_truly_stuck(delta: float)->void:
	if get_last_motion().is_equal_approx(Vector2(0,0)):
		position -= transform.x * speed * direction * delta


func animate()->void:
	muzzle_flash.global_position = get_parent().buster_spawn.global_position
	
	if get_parent().direction == 1:
		if get_parent().current_state == get_parent().MainState.WALL_SLIDING:
			muzzle_flash.flip_h = true
		else:
			muzzle_flash.flip_h = false
	else:
		if get_parent().current_state == get_parent().MainState.WALL_SLIDING:
			muzzle_flash.flip_h = false
		else:
			muzzle_flash.flip_h = true
	
	if direction == 1:
		sprite.flip_h = false
	else:
		sprite.flip_h = true
