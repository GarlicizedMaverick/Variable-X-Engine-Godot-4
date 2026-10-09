## TODO: Limit the number of simultaneous weapon instances
## TODO: Add charging
## TODO: Add behaviors for deflecting off of enemies that are immune to each weapon
# Stolen from Ludonauta
# https://ludonauta.itch.io/gameplay-library/devlog/1584673/tutorial-weapon-swapping-in-godot-4
class_name PlayerWeapons extends Node


signal weapon_changed(new_weapon: int)

@onready var player: Player = $".."

@export var lemon: PackedScene
@export var dash_lemon: PackedScene
@export var shotgun_ice: PackedScene
@export var electric_spark: PackedScene
@export var rolling_shield: PackedScene

const X1_WEAPON_NAMES: Array[String] =\
[
	"SHOTGUN ICE",
	"ELECTRIC SPARK",
	"ROLLING SHIELD",
	"HOMING TORPEDO",
	"BOOMERANG CUTTER",
	"CHAMELEON STING",
	"STORM TORNADO",
	"FIRE WAVE"
]

# The values will be used as the order that the weapons get switched.
# I intend on letting the player edit the order to their liking.
# This will affect the positions on the weapon wheel as well.
# By default, it's the same as the original X1.
var mmx_weapons: Dictionary[String, int] =\
{
	"X-BUSTER": 0,
	"SHOTGUN ICE": 8,
	"ELECTRIC SPARK": 6,
	"ROLLING SHIELD": 3,
	"HOMING TORPEDO": 1,
	"BOOMERANG CUTTER": 7,
	"CHAMELEON STING": 2,
	"STORM TORNADO": 5,
	"FIRE WAVE": 4
}

var current_weapon: int = 0: set = set_weapon
var available_weapons: Array[String] = ["X-BUSTER"]

var stats: PlayerStats
var direction: int
var buster_spawn: Marker2D


func set_weapon(slot: int)->void:
	current_weapon = wrapi(slot, 0, available_weapons.size())
	weapon_changed.emit(current_weapon)


func _ready()->void:
	stats = player.stats
	
	MMXManager.mavericks_defeated = 7 # Here for testing purposes
	MMXManager.number_of_maverick_stages_beaten = 3
	
	if GameManager.current_game_mode == GameManager.GameMode.MMX:
		get_available_weapons()
		#set_weapon_order()
		
		
	else:
		# We'll get to EP when we get there...
		pass
	
	current_weapon = 0


func _physics_process(_delta: float)->void:
	#print(current_weapon)
	
	direction = player.direction
	buster_spawn = player.buster_spawn
	
	if Input.is_action_just_pressed("weapon_switch_left"):
		previous_weapon()
	elif Input.is_action_just_pressed("weapon_switch_right"):
		next_weapon()
	
	if Input.is_action_just_pressed("shoot_secondary"):
		handle_lemons()
	if Input.is_action_just_pressed("shoot_primary"):
		# I'll do custom weapon order shenanigans later (and a proper match statement)
		if current_weapon == 0:
			handle_lemons()
		elif current_weapon == 1:
			handle_shotgun_ice()
		elif current_weapon == 2:
			handle_electric_spark()
		elif current_weapon == 3:
			handle_rolling_shield()


func handle_lemons()->void:
	if player.current_state == player.MainState.DASHING or player.dashing_to_airborne:
		var new_dash_lemon: HitBox2D = dash_lemon.instantiate()
		player.add_child(new_dash_lemon)
		new_dash_lemon.top_level = true # DO THIS IMMEDIATELY
		
		new_dash_lemon.global_position = buster_spawn.global_position
		new_dash_lemon.speed = new_dash_lemon.BASE_SPEED * stats.buster_shot_speed_mult
		
		if player.current_state == player.MainState.WALL_SLIDING:
			new_dash_lemon.direction = -direction
		else:
			new_dash_lemon.direction = direction
	else:
		var new_lemon: HitBox2D = lemon.instantiate()
		player.add_child(new_lemon)
		new_lemon.top_level = true
		
		new_lemon.global_position = buster_spawn.global_position
		new_lemon.max_speed = new_lemon.BASE_MAX_SPEED * stats.buster_shot_speed_mult
		new_lemon.acceleration = new_lemon.BASE_ACCELERATION * stats.buster_shot_speed_mult
		
		new_lemon.initial_speed = new_lemon.BASE_INITIAL_SPEED * stats.buster_shot_speed_mult
		new_lemon.speed = new_lemon.initial_speed
		
		if player.current_state == player.MainState.WALL_SLIDING:
			new_lemon.direction = -direction
		else:
			new_lemon.direction = direction


func handle_shotgun_ice()->void:
	# Speed is not affected by buster_shot_speed_mult (it's already so fast)
	var new_shotgun_ice: HitBox2D = shotgun_ice.instantiate()
	player.add_child(new_shotgun_ice)
	new_shotgun_ice.top_level = true
	
	new_shotgun_ice.global_position = buster_spawn.global_position
	
	if player.current_state == player.MainState.WALL_SLIDING:
		new_shotgun_ice.direction = -direction
	else:
		new_shotgun_ice.direction = direction


func handle_electric_spark()->void:
	var new_espark: HitBox2D = electric_spark.instantiate()
	player.add_child(new_espark)
	new_espark.top_level = true
	
	new_espark.global_position = buster_spawn.global_position
	new_espark.speed = new_espark.BASE_SPEED * stats.buster_shot_speed_mult
	
	if player.current_state == player.MainState.WALL_SLIDING:
		new_espark.direction = -direction
	else:
		new_espark.direction = direction


func handle_rolling_shield()->void:
	var new_rolling_shield: CharacterBody2D = rolling_shield.instantiate()
	player.add_child(new_rolling_shield)
	new_rolling_shield.top_level = true
	
	if player.current_state == player.MainState.WALL_SLIDING:
		new_rolling_shield.direction = -direction
	else:
		new_rolling_shield.direction = direction
	
	#if Input.is_action_pressed("dpad_up"):
		#new_rolling_shield.initial_velocity_y = new_rolling_shield.KICKED_BY_X_RISING_SPEED
	#else:
		#new_rolling_shield.initial_velocity_y = new_rolling_shield.NORMAL_INITIAL_RISING_SPEED
	
	var slope_offset_y: int
	var slope_offset_y_amplifier: int
	
	# I had to create an entirely new (and ACCURATE) player function just for you, Rolling Shield.
	# Oy vey!
	if player.facing_up_slope():
		match player.get_accurate_floor_angle():
			0 or 14:
				slope_offset_y = 0
				slope_offset_y_amplifier = 0
			18:
				# Not required, but makes it look nicer.
				slope_offset_y = -4
				slope_offset_y_amplifier = 2
			26:
				# Required for functional shooting up slopes.
				slope_offset_y = -8
				slope_offset_y_amplifier = 3
			45:
				# Also required for functional shooting up slopes.
				slope_offset_y = -24
				slope_offset_y_amplifier = 2
	else:
		slope_offset_y = 0
	
	var dashing_near_wall_offset: int
	if player.near_wall():
		dashing_near_wall_offset = 13
	else:
		dashing_near_wall_offset = 0
	
	# Shooting effect
	new_rolling_shield.muzzle_flash.global_position = buster_spawn.global_position
	if direction == 1:
		new_rolling_shield.sprite.flip_h = false # This line is here for completeness.
		new_rolling_shield.muzzle_flash.flip_h = false
	elif direction == -1:
		# Without this specific line, the Rolling Shield sprite faces the wrong way on frame 1.
		new_rolling_shield.sprite.flip_h = true 
		new_rolling_shield.muzzle_flash.flip_h = true
	
	# Attempt at not getting the Rolling Shield immediately stuck
	if player.current_state == player.MainState.DASHING:
			new_rolling_shield.global_position =\
			buster_spawn.global_position -\
			Vector2(dashing_near_wall_offset * new_rolling_shield.direction,\
			10 + -(slope_offset_y * slope_offset_y_amplifier))
	else:
		new_rolling_shield.global_position =\
		Vector2(buster_spawn.global_position.x, buster_spawn.global_position.y + slope_offset_y)


func get_available_weapons()->void:
	# Get the names of the currently active 'mavericks_defeated' flags.
	for i: int in range(X1_WEAPON_NAMES.size()):
		var flag: int = 1 << i
		
		# Each weapon corresponds to a defeated maverick.
		if MMXManager.mavericks_defeated & flag:
			available_weapons.append(X1_WEAPON_NAMES[i])


func set_weapon_order()->void:
	pass


func previous_weapon()->void:
	set_weapon(current_weapon - 1)


func next_weapon()->void:
	set_weapon(current_weapon + 1)
