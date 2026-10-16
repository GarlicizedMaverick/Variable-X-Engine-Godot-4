class_name EnemySpiky extends BaseEnemy


@onready var animator: AnimationPlayer = $AnimationPlayer
@onready var collider_rolling: CollisionShape2D = $ColliderRolling
@onready var collider_defeated: CollisionShape2D = $ColliderDefeated
@onready var hitbox_rolling: HitBox2D = $HitBoxRolling
@onready var hitbox_defeated: HitBox2D = $HitBoxDefeated
@onready var hurtbox_rolling: HurtBox2D = $HurtBoxRolling
@onready var hurtbox_defeated: HurtBox2D = $HurtBoxDefeated
@onready var graze_hurtbox: HurtBox2D = $GrazeHurtBox
@onready var player: Player = $"../../../../../../EntityRoot/Player"
@onready var ray_wall_detector: RayCast2D = $RayWallDetector
@onready var screen_notif: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
@onready var spawner: Spawner = self.get_parent()

@export var stats: EnemyStats
@export var damage_table: MMXEnemyDamageTable
@export var initial_direction: InitialDirection = InitialDirection.TOWARD_PLAYER

const SPEED: int = 180 # I don't know the exact number, but it's just barely faster than walking X.
const DECELERATION: int = 180 # I don't know the exact number, but this feels nice.
const TURN_JUMP_VELOCITY: int = -600 # I don't know the exact number, but this looks close.
const TERMINAL_VELOCITY: int = 690 # I don't even know if it's capped. I'm just using X's.
const GRAVITY: int = 3600 # I don't know the exact number, but it's definitely higher than X's.
const LEFT_OF_PLAYER: String = "Left of Player"
const RIGHT_OF_PLAYER: String = "Right of Player"

var speed: float = SPEED

enum InitialDirection
{
	LEFT = 0,
	RIGHT,
	TOWARD_PLAYER,
	AWAY_FROM_PLAYER
}

var current_state: MainState
enum MainState
{
	ROLLING = 0,
	TURNING,
	FLIPPING
}

var direction: int


func _ready()->void:
	add_to_group("Enemies")
	stats.health = stats.max_health
	
	stats.health_depleted.connect(_on_health_depleted)
	hurtbox_rolling.damage_taken.connect(_on_damage_taken)
	hurtbox_defeated.damage_taken.connect(_on_damage_taken)
	graze_hurtbox.damage_taken.connect(_on_grazed)
	animator.connect("animation_finished", _on_animation_finished)
	screen_notif.screen_exited.connect(_on_screen_exited)
	
	current_state = MainState.ROLLING
	
	set_direction()


func _on_screen_exited()->void:
	queue_free()


func _on_damage_taken(hitbox: HitBox2D)->void:
	var id: String = hitbox.identifier
	var damage: float = damage_table.damage_table.get(id)
	
	if id == "Hadouken Weak" or id == "Hadouken" or id == "Pseudoken":
		# Player attack power doesn't affect the Hadoukens
		stats.health -= damage
	else:
		if hitbox.continuous == true:
			var delta: float = (1.0/Engine.physics_ticks_per_second)
			stats.health -= damage * player.stats.attack_power * delta
			hitbox.set_active_continuous()
		else:
			if id == "Dash Lemon" and stats.health >= 2 and player.stats.attack_power < 1.5:
				# Dash Lemons only do 1 damage if the Spiky has already been hit.
				# This is SNES-accurate behavior, though I may change this.
				# Regardless, I've made it so if X's attack power is high enough, it doesn't matter.
				stats.health = 1
			else:
				stats.health -= damage * player.stats.attack_power
	
	if stats.health <= 1:
		if !is_on_floor():
			# Instantly die if in air. SNES-accurate behavior.
			spawner.entity_currently_on_screen = false
			self.queue_free()
		else:
			animator.play("flip over")
			current_state = MainState.FLIPPING
	
	flash_briefly()


func _on_grazed(hitbox: HitBox2D)->void:
	var id: String = hitbox.identifier
	var damage: float = damage_table.damage_table.get(id)
	
	if (damage * player.stats.attack_power) >= 2 and stats.health == stats.max_health:
		stats.health = 1
		animator.play("flip over")
		current_state = MainState.FLIPPING
	else:
		if id == "Dash Lemon" and stats.health >= 2 and player.stats.attack_power < 1.5:
				# Dash Lemons only do 1 damage if the Spiky has already been hit.
				# And yes, that applies to the graze area as well.
				# This is SNES-accurate behavior, though I may change this.
				# Regardless, I've made it so if X's attack power is high enough, it doesn't matter.
				stats.health = 1
		else:
			stats.health -= damage * player.stats.attack_power
	
	if stats.health <= 1:
		if !is_on_floor():
			# Instantly die if in air. SNES-accurate behavior.
			spawner.entity_currently_on_screen = false
			self.queue_free()
		else:
			animator.play("flip over")
			current_state = MainState.FLIPPING
	
	flash_briefly()


func _on_health_depleted()->void:
	spawner.entity_currently_on_screen = false
	self.queue_free()


func flash_briefly()->void:
	# This is certainly NOT going to be the final implementation of damage flashing.
	# This is just a quick and dirty placeholder.
	self.modulate = Color(2, 2, 2, 1)
	await get_tree().physics_frame
	await get_tree().physics_frame
	await get_tree().physics_frame
	await get_tree().physics_frame
	await get_tree().physics_frame
	await get_tree().physics_frame
	await get_tree().physics_frame
	await get_tree().physics_frame
	self.modulate = Color(1, 1, 1, 1)


func _on_animation_finished(anim_name: String)->void:
	if anim_name == "flip over":
		animator.play("tumble")
		animator.speed_scale = 1.5
	elif anim_name == "tumble":
		animator.play("just lie there")
	elif anim_name == "just lie there":
		spawner.entity_currently_on_screen = false
		queue_free()


func _physics_process(delta: float)->void:
	handle_colliders()
	update_state_machine(delta)
	move_and_slide()


func set_direction()->void:
	match initial_direction:
		InitialDirection.LEFT:
			direction = -1
		InitialDirection.RIGHT:
			direction = 1
		InitialDirection.TOWARD_PLAYER:
			if get_position_relative_to_player() == LEFT_OF_PLAYER:
				direction = 1
			else:
				direction = -1
		InitialDirection.AWAY_FROM_PLAYER:
			if get_position_relative_to_player() == LEFT_OF_PLAYER:
				direction = -1
			else:
				direction = 1


func get_position_relative_to_player()->String:
	if global_position.x < player.global_position.x:
		return LEFT_OF_PLAYER
	else:
		return RIGHT_OF_PLAYER


func update_state_machine(delta: float)->void:
	match current_state:
		MainState.ROLLING:
			roll()
			handle_gravity(delta)
			handle_direction()
			animator.play("rolling")
			
			# Transition Logic
			if ray_wall_detector.is_colliding():
				direction *= -1 # Bounce off wall, but don't enter TURNING state.
				if is_on_floor():
					# Enter TURNING STATE
					velocity.y = TURN_JUMP_VELOCITY
					if direction == 1:
						animator.play("turn_left")
					else:
						animator.play("turn_right")
					current_state = MainState.TURNING
		
		MainState.TURNING:
			handle_gravity(delta)
			handle_direction()
			
			if velocity.y > 0:
				animator.play("RESET")
			
			# Transition Logic
			if is_on_floor():
				current_state = MainState.ROLLING
		
		MainState.FLIPPING:
			handle_gravity(delta)
			handle_deceleration(delta)


func roll()->void:
	velocity.x = SPEED * direction


func handle_gravity(delta: float)->void:
	velocity.y += GRAVITY * delta
	if velocity.y >= TERMINAL_VELOCITY:
		velocity.y = TERMINAL_VELOCITY


func handle_direction()->void:
	if direction == 1:
		ray_wall_detector.target_position.x = 36
	else:
		ray_wall_detector.target_position.x = -36


func handle_deceleration(delta: float)->void:
	speed -= DECELERATION * delta
	speed = clampf(speed, 0, SPEED)
	velocity.x = speed * direction


func handle_colliders()->void:
	match current_state:
		MainState.ROLLING:
			collider_rolling.disabled = false
			collider_defeated.disabled = true
			
			hitbox_rolling.get_child(0).disabled = false
			hitbox_defeated.get_child(0).disabled = true
			
			hurtbox_rolling.get_child(0).disabled = false
			hurtbox_defeated.get_child(0).disabled = true
			graze_hurtbox.get_child(0).disabled = false
		
		#MainState.TURNING:
			#collider_rolling.disabled = false
			#collider_defeated.disabled = true
			#
			#hitbox_rolling.get_child(0).disabled = false
			#hitbox_defeated.get_child(0).disabled = true
			#
			#hurtbox_rolling.get_child(0).disabled = false
			#hurtbox_defeated.get_child(0).disabled = true
			#graze_hurtbox.get_child(0).disabled = false
		
		MainState.FLIPPING:
			collider_rolling.disabled = true
			collider_defeated.disabled = false
			
			hitbox_rolling.get_child(0).disabled = true
			if velocity.is_equal_approx(Vector2.ZERO):
				# Disable the hitbox if not moving (or just moving very slowly)
				hitbox_defeated.get_child(0).disabled = true
			else:
				hitbox_defeated.get_child(0).disabled = false
			
			hurtbox_rolling.get_child(0).disabled = true
			hurtbox_defeated.get_child(0).disabled = false
			graze_hurtbox.get_child(0).disabled = true
