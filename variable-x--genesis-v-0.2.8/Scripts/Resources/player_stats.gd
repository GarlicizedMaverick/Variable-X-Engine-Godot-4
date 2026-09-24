# Stolen from Queble
# https://www.youtube.com/watch?v=vsBb9921GfA
class_name PlayerStats extends Resource


signal health_depleted
signal health_changed(current_health: int, max_health: int)
signal ki_increased


@export_group("Core")
@export var base_max_health: int = 16
@export var attack_power: float = 1
@export_range(0, 1, 0.01) var defense: float = 0
@export_range(0, 1024, 1, "prefer_slider") var ki: int = 0

@export_group("Physics")
@export_subgroup("Speed/Walk")
@export var base_walk_speed_normal: float = 176.25
@export var base_walk_speed_14: float = 204.375
@export var base_walk_speed_18: float = 232.5
@export var base_walk_speed_26: float = 260.625
@export var base_walk_speed_45: float = 288.75
@export_subgroup("Speed/Dash")
@export var base_dash_speed: float = 414.84375

@export_subgroup("Jump")
@export var base_jump_velocity_normal: float = -660
@export var base_jump_velocity_14: float = -690
@export var base_jump_velocity_18: float = -720
@export var base_jump_velocity_26: float = -750
@export var base_jump_velocity_45: float = -780
@export var base_wall_jump_velocity: float = -420

@export_group("Other")
## Increases the recovery effects of Life and Weapon refill pickups, including refilling sub-tanks
@export_range(1, 2, 0.5) var energy_recovery_effect: float = 1
## Reduces the cost of weapon energy
@export var energy_conservation: float = 0
## Damage taken is converted into weapon energy. Also fills the weapon sub-tank
@export var damage_converter: bool = false
## Increases the invincibility period after taking damage (in seconds)
@export_range(1.5, 3, 0.5) var invincibility_period: float = 1.5
## Reduces the X-Buster’s charge time
@export var charge_time_reduction: float = 1
## Increases the maximum number of default X-Buster shots on-screen
@export_range(3, 5, 1, "prefer_slider") var max_buster_shots: int = 3
## Increases projectile speed (and acceleration) of default X-Buster shots
@export_range(1, 1.5, 0.05) var buster_shot_speed_mult: float = 1

const MAX_HEALTH_EP: int = 28

var current_max_health: int = 16
var health: int = 0: set = _on_health_set

var walk_speed_normal: float = base_walk_speed_normal
var walk_speed_14: float = base_walk_speed_14
var walk_speed_18: float = base_walk_speed_18
var walk_speed_26: float = base_walk_speed_26
var walk_speed_45: float = base_walk_speed_45
var dash_speed: float = base_dash_speed

var jump_velocity_normal: float = base_jump_velocity_normal
var jump_velocity_14: float = base_jump_velocity_14
var jump_velocity_18: float = base_jump_velocity_18
var jump_velocity_26: float = base_jump_velocity_26
var jump_velocity_45: float = base_jump_velocity_45
var wall_jump_velocity: float = base_wall_jump_velocity


func _init()->void:
	setup_stats.call_deferred()


func setup_stats()->void:
	# Recalculate the current stats first
	if GameManager.current_game_mode == GameManager.GameMode.MMX:
		current_max_health = base_max_health + (2 * MMXManager.number_of_heart_tanks_collected)
		ki_check()
		#print(attack_power)
	else:
		current_max_health = MAX_HEALTH_EP
		ki = 0
	health = current_max_health


func ki_check()->void:
	set_attack_power()
	set_move_speed()
	set_jump_velocity()
	set_super_recover()
	set_barrier_extension()
	set_quick_charge()
	set_buster_shot_extenderator()
	set_buster_shot_rapidizer()
	set_damage_converter()
	set_weapon_energy_conservation()


func set_attack_power()->void:
	# Attack power increases by one percent for every point of Ki
	attack_power = 1.0 + (ki/100.0)


func set_move_speed()->void:
	# Handle walk speed
	if ki <= 10:
		walk_speed_normal = base_walk_speed_normal
		walk_speed_14 = base_walk_speed_14
		walk_speed_18 = base_walk_speed_18
		walk_speed_26 = base_walk_speed_26
		walk_speed_45 = base_walk_speed_45
	else:
		walk_speed_normal = 180
		walk_speed_14 = 210
		walk_speed_18 = 240
		walk_speed_26 = 270
		walk_speed_45 = 300
	
	# Handle dash/buster speed
	match true:
		_ when ki <= 4:
			dash_speed = base_dash_speed
			buster_shot_speed_mult = 1
		
		_ when ki >= 5 and ki <= 8:
			dash_speed = 440.625
			buster_shot_speed_mult = 1.0625
		
		_ when ki >= 9 and ki <= 12:
			dash_speed = 466.640625
			buster_shot_speed_mult = 1.125
		
		_ when ki >= 13 and ki <= 16:
			dash_speed = 492.65625
			buster_shot_speed_mult = 1.1875
		
		_ when ki >= 17 and ki <= 20:
			dash_speed = 518.4375
			buster_shot_speed_mult = 1.25
		
		_ when ki >= 21 and ki <= 24:
			dash_speed = 544.453125
			buster_shot_speed_mult = 1.3125
		
		_ when ki >= 25 and ki <= 32:
			dash_speed = 570.46875
			buster_shot_speed_mult = 1.375
		
		_ when ki >= 33 and ki <= 48:
			dash_speed = 596.25
			buster_shot_speed_mult = 1.4375
		
		_ when ki >= 49:
			dash_speed = 622.265625
			buster_shot_speed_mult = 1.5


func set_jump_velocity()->void:
	# Slope speed/height is completely altered
	# Base jump height is slightly increased to compensate for the shorter hitbox
	match true:
		_ when ki <= 4:
			jump_velocity_normal = base_jump_velocity_normal
			jump_velocity_14 = base_jump_velocity_14
			jump_velocity_18 = base_jump_velocity_18
			jump_velocity_26 = base_jump_velocity_26
			jump_velocity_45 = base_jump_velocity_45
			wall_jump_velocity = base_wall_jump_velocity
		
		_ when ki >= 5 and ki <= 8:
			jump_velocity_normal = -693
			jump_velocity_14 = base_jump_velocity_14 * 1.05
			jump_velocity_18 = base_jump_velocity_18 * 1.05
			jump_velocity_26 = base_jump_velocity_26 * 1.05
			jump_velocity_45 = base_jump_velocity_45 * 1.05
			wall_jump_velocity = base_wall_jump_velocity * 1.05
		
		_ when ki >= 9 and ki <= 12:
			jump_velocity_normal = -726
			jump_velocity_14 = base_jump_velocity_14 * 1.1
			jump_velocity_18 = base_jump_velocity_18 * 1.1
			jump_velocity_26 = base_jump_velocity_26 * 1.1
			jump_velocity_45 = base_jump_velocity_45 * 1.1
			wall_jump_velocity = base_wall_jump_velocity * 1.1
		
		_ when ki >= 13 and ki <= 16:
			jump_velocity_normal = -759
			jump_velocity_14 = base_jump_velocity_14 * 1.15
			jump_velocity_18 = base_jump_velocity_18 * 1.15
			jump_velocity_26 = base_jump_velocity_26 * 1.15
			jump_velocity_45 = base_jump_velocity_45 * 1.15
			wall_jump_velocity = base_wall_jump_velocity * 1.2
		
		_ when ki >= 17 and ki <= 20:
			jump_velocity_normal = -792
			jump_velocity_14 = base_jump_velocity_14 * 1.2
			jump_velocity_18 = base_jump_velocity_18 * 1.2
			jump_velocity_26 = base_jump_velocity_26 * 1.2
			jump_velocity_45 = base_jump_velocity_45 * 1.2
			wall_jump_velocity = base_wall_jump_velocity * 1.3
		
		_ when ki >= 21 and ki <= 24:
			jump_velocity_normal = -825
			jump_velocity_14 = base_jump_velocity_14 * 1.25
			jump_velocity_18 = base_jump_velocity_18 * 1.25
			jump_velocity_26 = base_jump_velocity_26 * 1.25
			jump_velocity_45 = base_jump_velocity_45 * 1.25
			wall_jump_velocity = base_wall_jump_velocity * 1.4
		
		_ when ki >= 25:
			jump_velocity_normal = -858
			jump_velocity_14 = base_jump_velocity_14 * 1.3
			jump_velocity_18 = base_jump_velocity_18 * 1.3
			jump_velocity_26 = base_jump_velocity_26 * 1.3
			jump_velocity_45 = base_jump_velocity_45 * 1.3
			wall_jump_velocity = base_wall_jump_velocity * 1.5


func set_super_recover()->void:
	match true:
		_ when ki <= 7:
			energy_recovery_effect = 1
		
		_ when ki >= 8 and ki <= 15:
			energy_recovery_effect = 1.5
		
		_ when ki >= 16:
			energy_recovery_effect = 2


func set_barrier_extension()->void:
	match true:
		_ when ki <= 6:
			invincibility_period = 1.5
		
		_ when ki >= 7 and ki <= 14:
			invincibility_period = 2
		
		_ when ki >= 15 and ki <= 31:
			invincibility_period = 2.5
		
		_ when ki >= 32:
			invincibility_period = 3


func set_quick_charge()->void:
	match true:
		_ when ki <= 6:
			charge_time_reduction = 1
		
		_ when ki >= 7 and ki <= 14:
			# 15% quicker
			charge_time_reduction = 1/0.85
		
		_ when ki >= 15 and ki <= 23:
			# 30% quicker
			charge_time_reduction = 1/0.7
		
		_ when ki >= 24:
			# 50% quicker
			charge_time_reduction = 2


func set_buster_shot_extenderator()->void:
	match true:
		_ when ki <= 13:
			max_buster_shots = 3
		
		_ when ki >= 14 and ki <= 23:
			max_buster_shots = 4
		
		_ when ki >= 24:
			max_buster_shots = 5


func set_buster_shot_rapidizer()->void:
	match true:
		_ when ki <= 7:
			buster_shot_speed_mult = 1
		
		_ when ki >= 8 and ki <= 15:
			buster_shot_speed_mult = 1.05
		
		_ when ki >= 16 and ki <= 31:
			buster_shot_speed_mult = 1.1
		
		_ when ki >= 32 and ki <= 47:
			buster_shot_speed_mult = 1.15
		
		_ when ki >= 48:
			buster_shot_speed_mult = 1.2


func set_damage_converter()->void:
	if ki >= 6:
		damage_converter = true
	else:
		damage_converter = false


func set_weapon_energy_conservation()->void:
	match true:
		_ when ki <= 4:
			energy_conservation = 1
		
		_ when ki >= 5 and ki <= 7:
			# Reduce weapon energy cost by 10%
			energy_conservation = 1/0.9
		
		_ when ki >= 8 and ki <= 11:
			# Reduce weapon energy cost by 20%
			energy_conservation = 1.25
		
		_ when ki >= 12 and ki <= 15:
			# Reduce weapon energy cost by 30%
			energy_conservation = 1/0.7
		
		_ when ki >= 16 and ki <= 19:
			# Reduce weapon energy cost by 40%
			energy_conservation = 1/0.6
		
		_ when ki >= 20 and ki <= 24:
			# Reduce weapon energy cost by 50%
			energy_conservation = 2
		
		_ when ki >= 25 and ki <= 63:
			#Reduce weapon energy cost by 75%
			energy_conservation = 4
		
		_ when ki >= 64:
			# Infinite weapon energy
			energy_conservation = INF


func _on_health_set(new_value: int)->void:
	health = clampi(new_value, 0, current_max_health)
	health_changed.emit(health, current_max_health)
	if health <= 0:
		health_depleted.emit()


func _on_ki_increased()->void:
	ki_check()
