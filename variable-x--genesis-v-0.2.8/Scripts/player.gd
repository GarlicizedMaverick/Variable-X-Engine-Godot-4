class_name Player extends CharacterBody2D


#region CLASS VARIABLES
@onready var sprite: AnimatedSprite2D = $Sprite
@onready var collider: CollisionShape2D = $Collider
@onready var hurtbox: HurtBox2D = $HurtBox2D
@onready var ray_ceiling_left: RayCast2D = $Sensors/RayCeilingLeft
@onready var ray_ceiling_right: RayCast2D = $Sensors/RayCeilingRight
@onready var ray_ceiling_dash_left: RayCast2D = $Sensors/RayCeilingDashLeft
@onready var ray_ceiling_dash_right: RayCast2D = $Sensors/RayCeilingDashRight
@onready var ray_floor_left: RayCast2D = $Sensors/RayFloorLeft
@onready var ray_floor_right: RayCast2D = $Sensors/RayFloorRight
@onready var ray_floor_sg_left: RayCast2D = $Sensors/RayFloorSafeguardLeft
@onready var ray_floor_sg_right: RayCast2D = $Sensors/RayFloorSafeguardRight
@onready var ray_wl_top: RayCast2D = $Sensors/RayWallLeftTop
@onready var ray_wl_center: RayCast2D = $Sensors/RayWallLeftCenter
@onready var ray_wl_bottom: RayCast2D = $Sensors/RayWallLeftBottom
@onready var ray_wr_top: RayCast2D = $Sensors/RayWallRightTop
@onready var ray_wr_center: RayCast2D = $Sensors/RayWallRightCenter
@onready var ray_wr_bottom: RayCast2D = $Sensors/RayWallRightBottom
@onready var camera_zone_collider: Area2D = $Sensors/CameraZoneCollider
@onready var dash_timer: Timer = $DashTimer
@onready var wall_grab_timer: Timer = $WallGrabTimer
@onready var wall_jump_timer: Timer = $WallJumpTimer
@onready var knockback_timer: Timer = $KnockbackTimer
@onready var i_frame_timer: Timer = $IFrameTimer
@onready var tiptoe_timer: Timer = $TiptoeTimer
@onready var coyote_timer: Timer = $CoyoteTimer
@onready var jump_buffer_timer: Timer = $JumpBufferTimer
@onready var camera: Camera2D = $Camera
@onready var buster_spawn: Marker2D = $BusterSpawn

@export var stats: PlayerStats
@export var lemon: PackedScene

# Values are mostly borrowed from the SNES Mega Man X titles
	# Slope speed/height is completely altered
	# Base jump height is slightly increased to compensate for the shorter hitbox
	# Values are also doubled due to the game's 2x scaled sprites/tiles

const GRAVITY_NORMAL: int = 1800
const GRAVITY_WATER: float = 928.125

const TIPTOE_SPEED: int = 120

const LADDER_SPEED_NORMAL: float = 176.25
const LADDER_SPEED_ARM_OR_LEG: float = 264.375
const LADDER_SPEED_ARM_AND_LEG: float = 352.5

const IMMEDIATE_FALL_VELOCITY: int = 30    # (NOT halved when underwater)

const TERMINAL_VELOCITY_NORMAL: int = 690
const TERMINAL_VELOCITY_WATER: float = 345.46875

const KNOCKBACK_VELOCITY: Vector2 = Vector2(64.6875, -240)

const WALL_SLIDE_SPEED_NORMAL: int = 240
const WALL_SLIDE_SPEED_WATER: int = 120

const WALL_JUMP_VELOCITY: int = -420    # Random value that feels nice.
const WALL_SNAP_CHECK: int = 8
const WALL_SNAP_AMOUNT: int = 16

const UNIT: float = 1.0/256

# PHYSICS CONTAINERS
var speed: float
var dash_speed: float
var jump_velocity: float
var gravity: float = GRAVITY_NORMAL
var terminal_velocity: float = TERMINAL_VELOCITY_NORMAL
var wall_slide_speed: float = WALL_SLIDE_SPEED_NORMAL

# OTHER VARIABLES
var direction: int = 1
var dpad: Vector2 = Vector2.ZERO
var i_frames_total: int
var i_frames_left: int

# STATE MACHINE SET UP
var current_state: MainState
enum MainState
{
	IDLE = 0,
	WALKING,
	DASHING,
	AIR_DASHING,
	JUMPING,
	FALLING,
	WALL_SLIDING,
	WALL_JUMPING,
	ON_LADDER,
	TAKING_DAMAGE
}
# State Transition Trackers
var dashing_to_airborne: bool = 0

# State Bitflags
var is_shooting: bool = 0 # This might move into an 'XWeaponsController' script.
var is_on_left_wall: bool = 0
var is_on_right_wall: bool = 0
var taking_damage: bool = 0
var ps_jump_dash_enabled: bool = false
var super_dash_enabled: bool = false
var tiptoe_enabled: bool = true
#endregion


func _ready()->void:
	safe_margin = UNIT * 8
	current_state = MainState.IDLE
	speed = stats.walk_speed_normal
	dash_speed = stats.dash_speed
	jump_velocity = stats.jump_velocity_normal
	@warning_ignore("narrowing_conversion")
	i_frames_total = stats.invincibility_period * Engine.physics_ticks_per_second
	i_frames_left = i_frames_total
	hurtbox.damage_taken.connect(_on_damage_taken)


func _physics_process(delta: float)->void:
	print(dashing_to_airborne)
	handle_colliders()
	update_state_machine(delta)
	handle_position()
	move_and_slide()
	animate()
	shoot()


func _on_damage_taken(hitbox: HitBox2D)->void:
	var reduction: float = 1.0 - stats.defense
	stats.health -= floor(hitbox.damage * reduction)
	
	hurtbox.set_invincibility_period(stats.invincibility_period)
	i_frame_timer.start(stats.invincibility_period)
	
	reset_dash_transition()
	
	if current_state != MainState.WALL_SLIDING:
		velocity.y = KNOCKBACK_VELOCITY.y
		knockback_timer.start()
		current_state = MainState.TAKING_DAMAGE
	else:
		# This cancels the knockback effect if X is sliding down a wall.
		# The SNES/GBC games uncling X from the wall, but let him recling to it almost immediately.
		# The games from the PlayStation and onwards don't let you re-grab at all.
		## Without this else, X would continue to slide down the wall without interruption.
		## Delete this statement if that's how you'd prefer it.
		current_state = MainState.FALLING


func update_state_machine(delta: float)->void:
	match current_state:
		#region IDLE
		MainState.IDLE:
			reset_dash_transition()
			get_direction()
			if !under_high_ceiling():
				handle_jump()
			
			# Transition logic
			if !jump_buffer_timer.is_stopped() and Input.is_action_pressed("jump"):
				jump_buffer_timer.stop()
				handle_buffered_jump()
				current_state = MainState.JUMPING
			
			if is_on_floor():
				if dpad.x:
					tiptoe_timer.start()
					current_state = MainState.WALKING
				if Input.is_action_just_pressed("dash"):
					dash_timer.start()
					current_state = MainState.DASHING
				if Input.is_action_just_pressed("jump") and !under_high_ceiling():
					if ps_jump_dash_enabled and Input.is_action_pressed("dash"):
						dashing_to_airborne = true
					current_state = MainState.JUMPING
			else:
				coyote_timer.start()
				current_state = MainState.FALLING
		#endregion
		
		#region WALKING
		MainState.WALKING:
			reset_dash_transition()
			get_direction()
			if !under_high_ceiling():
				handle_jump()
			handle_walking()
			
			# Transition logic
			if !jump_buffer_timer.is_stopped() and Input.is_action_pressed("jump"):
				jump_buffer_timer.stop()
				handle_buffered_jump()
				current_state = MainState.JUMPING
			
			if is_on_floor():
				if !dpad.x:
					current_state = MainState.IDLE
				if Input.is_action_just_pressed("dash"):
					dash_timer.start()
					current_state = MainState.DASHING
				if Input.is_action_just_pressed("jump") and !under_high_ceiling():
					if ps_jump_dash_enabled and Input.is_action_pressed("dash"):
						dashing_to_airborne = true
					current_state = MainState.JUMPING
			else:
				coyote_timer.start()
				current_state = MainState.FALLING
		#endregion
		
		#region DASHING
		MainState.DASHING:
			## A SNES-accurate dash would get cancelled when inputting the opposite direction.
			## I prefer the Zero/ZX implementation, letting you change directions while dashing.
			## SNES X also prevents walking/dashing into a wall, whereas Zero/ZX do not.
			## Once again, I implemented the Zero/ZX style.
			get_direction()
			handle_dashing()
			# I've implemented the dash to act more like the slide (passing through low ceilings)
			if !dashing_under_ceiling():
				if !under_high_ceiling():
					handle_jump()
					if !jump_buffer_timer.is_stopped() and Input.is_action_pressed("jump"):
						jump_buffer_timer.stop()
						handle_buffered_jump()
						current_state = MainState.JUMPING
				
				# Transition logic
				if (dash_timer.is_stopped() and !super_dash_enabled)\
				or (super_dash_enabled and !Input.is_action_pressed("dash"))\
				or Input.is_action_just_released("dash"):
					if dpad.x:
						current_state = MainState.WALKING
					else:
						velocity = Vector2.ZERO
						current_state = MainState.IDLE
				if Input.is_action_just_pressed("jump") and !under_high_ceiling():
					dashing_to_airborne = true
					current_state = MainState.JUMPING
				if !is_on_floor():
					dashing_to_airborne = true
					coyote_timer.start()
					current_state = MainState.FALLING
			else:
				if !Input.is_action_pressed("dash"):
					# This prevents the dash from ending immediately...
					# when you go under a ceiling then back out.
					dash_timer.stop()
				
				if !is_on_floor():
					dashing_to_airborne = true
					# No coyote time here for obvious reasons.
					current_state = MainState.FALLING
		#endregion
		
		#region JUMPING
		MainState.JUMPING:
			get_direction()
			get_walls()
			handle_jump()
			handle_walking()
			handle_gravity(delta)
			
			# Transition logic
			if velocity.y >= 0:
				if (is_on_left_wall or is_on_right_wall):
					reset_dash_transition()
					wall_grab_timer.start()
					current_state = MainState.WALL_SLIDING
				else:
					current_state = MainState.FALLING
		#endregion
		
		#region FALLING
		MainState.FALLING:
			get_direction()
			get_walls()
			handle_walking()
			handle_gravity(delta)
			
			if !coyote_timer.is_stopped():
				handle_jump()
			if Input.is_action_just_pressed("jump"):
				jump_buffer_timer.start()
			
			# Transition logic
			if velocity.y < 0:
				# For some inexplicable reason, if you jump on the same frame that you start a fall,
				# the jump velocity would be set as normal, but the state would still be "FALLING",
				# meaning the "jump" couldn't be canceled like normal, as well as having...
				# unintended effects near walls...
				# The player would wall slide upwards if the wall was grabbed while rising.
				# This single line fixes these issues.
				current_state = MainState.JUMPING
			
			if is_on_floor():
				if !dpad.x:
					if !(Input.is_action_just_pressed("dash")\
					or (Input.is_action_pressed("dash") and super_dash_enabled)):
						current_state = MainState.IDLE
					else:
						dash_timer.start()
						current_state = MainState.DASHING
				else:
					if !(Input.is_action_just_pressed("dash")\
					or (Input.is_action_pressed("dash") and super_dash_enabled)):
						current_state = MainState.WALKING
					else:
						dash_timer.start()
						current_state = MainState.DASHING
			elif is_on_left_wall or is_on_right_wall:
				## An accurate MMX-styled controller calls reset_dash_transition() here,
				## but I've always hated losing dash speed after barely nicking an overhang,
				## so I may comment it out, later. Feel free to do so!
				velocity = Vector2.ZERO
				reset_dash_transition()
				wall_grab_timer.start()
				current_state = MainState.WALL_SLIDING
			elif near_wall() and Input.is_action_just_pressed("jump"):
				handle_wall_jump()
				current_state = MainState.WALL_JUMPING
		#endregion
		
		#region WALL SLIDING
		MainState.WALL_SLIDING:
			dash_timer.stop()
			get_direction()
			handle_walking()
			handle_dashing()
			handle_walls()
			
			# Transition logic
			if (is_on_left_wall or is_on_right_wall) == false:
				if is_on_floor():
					if Input.is_action_pressed("dash") and super_dash_enabled:
						current_state = MainState.DASHING
					elif !dpad.x:
						current_state = MainState.IDLE
					else:
						current_state = MainState.WALKING
				else:
					velocity.y = IMMEDIATE_FALL_VELOCITY
					# Flip direction when letting go of a wall
					if !dpad.x: ## This prevents direction-flipping when sliding off a wall.
						if direction == 1:
							direction = -1
						else:
							direction = 1
					current_state = MainState.FALLING
			else:
				if Input.is_action_just_pressed("jump"):
					wall_jump_timer.start()
					if Input.is_action_pressed("dash"):
						speed = dash_speed
					current_state = MainState.WALL_JUMPING
		#endregion
		
		#region WALL JUMPING
		MainState.WALL_JUMPING:
			handle_gravity(delta)
			if Input.is_action_pressed("jump"):
				velocity.y = stats.wall_jump_velocity
			velocity.x = speed * -direction
			
			# Transition logic
			if Input.is_action_just_released("jump") or is_on_ceiling():
				## Releasing "jump" to cancel the wall jump isn't X series accurate,
				## but I prefer it this way (Zero/ZX style)
				velocity.y = 0
				current_state = MainState.FALLING
			if wall_jump_timer.is_stopped():
				if Input.is_action_pressed("jump"):
					current_state = MainState.JUMPING
				else:
					current_state = MainState.FALLING
		#endregion
		
		#region TAKING DAMAGE
		MainState.TAKING_DAMAGE:
			handle_gravity(delta)
			get_dpad()
			get_walls()
			handle_horizontal_knockback()
			
			# Transition logic
			if !knockback_timer.is_stopped():
				# This cancels the knockback effect if X tries to grab onto a wall.
				# This is a SNES/GBC only mechanic, as all future post-classic Mega Man titles...
				# ...don't let you grab back onto walls while in a knockback state.
				if wall_grabbing_while_in_knockback():
					velocity = Vector2.ZERO
					knockback_timer.stop()
					wall_grab_timer.start()
					current_state = MainState.WALL_SLIDING
				
				# This lets you wall jump even while being knocked back.
				# This is inaccurate to EVERY post-Classic Mega Man game.
				# I like the responsiveness, however.
				if near_wall() and Input.is_action_just_pressed("jump"):
					handle_wall_jump()
					current_state = MainState.WALL_JUMPING
			else:
				if is_on_floor():
					if !dpad.x:
						velocity = Vector2.ZERO
						current_state = MainState.IDLE
					elif dpad.x:
						tiptoe_timer.start()
						current_state = MainState.WALKING
					if (Input.is_action_just_pressed("dash")\
					or (Input.is_action_pressed("dash") and super_dash_enabled)):
						dash_timer.start()
						current_state = MainState.DASHING
				
				else:
					if (is_on_left_wall and dpad.x < 0) or (is_on_right_wall and dpad.x > 0):
						velocity = Vector2.ZERO
						reset_dash_transition()
						wall_grab_timer.start()
						current_state = MainState.WALL_SLIDING
					else:
						# Don't start coyote timer
						current_state = MainState.FALLING
		#endregion


func handle_gravity(delta: float)->void:
	velocity.y += gravity * delta
	
	# Obviously use TERMINAL_VELOCITY_NORMAL only if above water, but I'll implement that later...
	if velocity.y >= TERMINAL_VELOCITY_NORMAL:
		velocity.y = TERMINAL_VELOCITY_NORMAL


func handle_jump()->void:
	var angle: int = get_accurate_floor_angle()
	
	if Input.is_action_just_pressed("jump"):
		if !down_slope():
			jump_velocity = stats.jump_velocity_normal
		else:
			match angle:
				14:
					jump_velocity = stats.jump_velocity_14
				18:
					jump_velocity = stats.jump_velocity_18
				26:
					jump_velocity = stats.jump_velocity_26
				45:
					jump_velocity = stats.jump_velocity_45
		
		velocity.y = jump_velocity
	
	jump_cut()


func handle_buffered_jump()->void:
	jump_velocity = stats.jump_velocity_normal
	velocity.y = jump_velocity
	if Input.is_action_pressed("dash"):
		# Without this, you wouldn't have dash speed from a buffered dash jump...
		# if you didn't already have dash speed.
		speed = dash_speed
	jump_cut()


func jump_cut()->void:
	# Variable jump height (cuts jump when released)
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y = IMMEDIATE_FALL_VELOCITY


func get_dpad()->void:
	dpad.x = signf(Input.get_axis("dpad_left", "dpad_right"))
	dpad.y = signf(Input.get_axis("dpad_up", "dpad_down"))


func get_direction()->int:
	get_dpad()
	
	if dpad.x < 0:
		direction = -1
		return direction
	elif dpad.x > 0:
		direction = 1
		return direction
	else:
		direction = direction
		return direction


func handle_walking()->void:
	if dashing_to_airborne:
		speed = dash_speed
	
	
	elif tiptoe_enabled and !tiptoe_timer.is_stopped():
		# This is a 100% accurate implementation of the SNES X tiptoe
		if is_on_floor():
			speed = TIPTOE_SPEED
		else:
			speed = stats.walk_speed_normal
	
	elif down_slope():
		# Slope speed implementation. Speed increases with the slope's gradient.
		var angle: int = get_accurate_floor_angle()
		match angle:
			0:
				speed = stats.walk_speed_normal
			14:
				speed = stats.walk_speed_14
			18:
				speed = stats.walk_speed_18
			26:
				speed = stats.walk_speed_26
			45:
				speed = stats.walk_speed_45
	
	elif !down_slope() and is_on_floor():
		speed = stats.walk_speed_normal
	
	velocity.x = dpad.x * speed


func handle_dashing()->void:
	dash_speed = stats.dash_speed
	velocity.x = direction * dash_speed


func under_high_ceiling()->bool:
	if ray_ceiling_left.is_colliding() or ray_ceiling_right.is_colliding():
		return true
	else:
		return false


func under_low_ceiling()->bool:
	if ray_ceiling_dash_left.is_colliding() or ray_ceiling_dash_right.is_colliding():
		return true
	else:
		return false


func dashing_under_ceiling()->bool:
	if under_low_ceiling() and current_state == MainState.DASHING:
		return true
	else:
		return false


func reset_dash_transition()->void:
	dashing_to_airborne = false
	speed = stats.walk_speed_normal


func down_slope()->bool:
	var last_motion: Vector2 = get_last_motion()
	if last_motion.x != 0 and last_motion.y > 0 and is_on_floor():
		return true
	else:
		return false


func get_floor_angle_left()->int:
	if ray_floor_left.get_collider() is TileMapLayer:
		var tile_map_layer: TileMapLayer = ray_floor_left.get_collider()
		var cell: Vector2i = tile_map_layer.local_to_map(ray_floor_left.get_collision_point())
		var data: TileData = tile_map_layer.get_cell_tile_data(cell)
		
		if data != null:
			var angle: int = data.get_custom_data("FloorAngle")
			
			if ray_floor_right.is_colliding() and ray_floor_sg_right.is_colliding()\
			and ray_floor_left.is_colliding() and ray_floor_sg_left.is_colliding():
				return 0
			elif !ray_floor_sg_right.is_colliding()\
			or (ray_floor_sg_right.is_colliding() and angle > 0):
				return angle
			else:
				return 0
		else:
			return 0
	else:
		return 0


func get_floor_angle_right()->int:
	if ray_floor_right.get_collider() is TileMapLayer:
		var tile_map_layer: TileMapLayer = ray_floor_right.get_collider()
		var cell: Vector2i = tile_map_layer.local_to_map(ray_floor_right.get_collision_point())
		var data: TileData = tile_map_layer.get_cell_tile_data(cell)
		
		if data != null:
			var angle: int = data.get_custom_data("FloorAngle")
			
			if ray_floor_left.is_colliding() and ray_floor_sg_left.is_colliding()\
			and ray_floor_right.is_colliding() and ray_floor_sg_right.is_colliding():
				return 0
			elif !ray_floor_sg_left.is_colliding() or (ray_floor_sg_left.is_colliding() and angle > 0):
				return angle
			else:
				return 0
		else:
			return 0
	else:
		return 0


func get_accurate_floor_angle()->int:
	if get_floor_angle_left() == 0 and get_floor_angle_right() != 0:
		return get_floor_angle_right()
	elif get_floor_angle_right() == 0 and get_floor_angle_left() != 0:
		return get_floor_angle_left()
	elif get_floor_angle_left() == 0 and get_floor_angle_right() == 0:
		return 0
	else:
		return maxi(get_floor_angle_left(), get_floor_angle_right())


func near_left_wall()->bool:
	## All this does is check three RayCasts targeting the player's left.
	## I check the collision normal to exclude slopes, as this would detect sloped ground,
	## which isn't what we want, since we'll be using this for wall jumps when near a wall.
	## This is also why I used RayCasts instead of Areas.
	# A collision normal of Vector2.RIGHT constitutes a left wall.
	if (ray_wl_top.is_colliding() and ray_wl_top.get_collision_normal() == Vector2.RIGHT)\
	or (ray_wl_center.is_colliding() and ray_wl_center.get_collision_normal() == Vector2.RIGHT)\
	or (ray_wl_bottom.is_colliding() and ray_wl_bottom.get_collision_normal() == Vector2.RIGHT):
		return true
	else:
		return false


func near_right_wall()->bool:
	# A collision normal of Vector2.LEFT constitutes a right wall.
	if (ray_wr_top.is_colliding() and ray_wr_top.get_collision_normal() == Vector2.LEFT)\
	or (ray_wr_center.is_colliding() and ray_wr_center.get_collision_normal() == Vector2.LEFT)\
	or (ray_wr_bottom.is_colliding() and ray_wr_bottom.get_collision_normal() == Vector2.LEFT):
		return true
	else:
		return false


func near_wall()->bool:
	if near_left_wall() or near_right_wall():
		return true
	else:
		return false


func get_walls()->void:
	if !is_on_wall_only():
		is_on_left_wall = false
		is_on_right_wall = false
	else:
		## This is coded in a specific way due to how is_on_wall_only() works,
		## which in my original implementation made it so when moving away from a wall,
		## there would be a frame where being on the opposite wall was considered true.
		## This made it so X's y-velocity would erroneously reset.
		
		if dpad.x < 0 and test_move(global_transform, Vector2(dpad.x, 0)):
			is_on_left_wall = true
			is_on_right_wall = false
		elif dpad.x > 0 and test_move(global_transform, Vector2(dpad.x, 0)):
			is_on_right_wall = true
			is_on_left_wall = false
		else:
			is_on_left_wall = false
			is_on_right_wall = false


func handle_walls()->void:
	get_walls()
	if (is_on_left_wall or is_on_right_wall) and velocity.y >= 0:
		if wall_grab_timer.is_stopped():
			velocity.y = wall_slide_speed
		else:
			velocity.y = 0


func wall_grabbing_while_in_knockback()->bool:
	if current_state == MainState.TAKING_DAMAGE:
		if !is_on_wall_only():
			return false
		else:
			if (is_on_left_wall and dpad.x < 0) or (is_on_right_wall and dpad.x > 0):
				return true
			else:
				return false
	else:
		return false


func handle_wall_jump()->void:
	reset_dash_transition()
	if near_left_wall():
		direction = -1
		# Snaps X's x-position closer to the wall if he's not too close.
		if !test_move(global_transform, Vector2(-WALL_SNAP_CHECK, 0)):
			translate(Vector2(-WALL_SNAP_AMOUNT, 0))
	elif near_right_wall():
		direction = 1
		# Snaps X's x-position closer to the wall if he's not too close.
		if !test_move(global_transform, Vector2(WALL_SNAP_CHECK, 0)):
			translate(Vector2(WALL_SNAP_AMOUNT, 0))
	elif near_left_wall() and near_right_wall():
		direction = direction
	wall_jump_timer.start()
	if Input.is_action_pressed("dash"):
		speed = dash_speed
	else:
		## This 'else' prevents dash wall jumps when 'dash' isn't pressed,
		## otherwise you'd have dash speed from a 'nearby wall jump' from a dash fall.
		## This also prevents slope speed from affecting wall jump speed.
		speed = stats.walk_speed_normal


func handle_horizontal_knockback()->void:
	velocity.x = KNOCKBACK_VELOCITY.x * -direction


func handle_colliders()->void:
	const HEIGHT_NORMAL: float = 60
	const HEIGHT_DASH: float = 30
	
	if current_state == MainState.DASHING:
		collider.shape.size.y = HEIGHT_DASH
		collider.position.y = HEIGHT_DASH/2
		
		hurtbox.get_child(0).shape.size.y = HEIGHT_DASH
		hurtbox.position.y = HEIGHT_DASH/2
	else:
		collider.shape.size.y = HEIGHT_NORMAL
		collider.position.y = 0
		
		hurtbox.get_child(0).shape.size.y = HEIGHT_NORMAL
		hurtbox.position.y = 0


func handle_position()->void:
	var offset_x: int = 16
	const OFFSET_TOP: int = 24
	const OFFSET_BOT: int = 36
	
	match true:
		# X pushes into the edge of the screen more and more depending on his speed,
		# hence this mess here.
		_ when abs(velocity.x) == TIPTOE_SPEED:
			offset_x = 18
		
		_ when abs(velocity.x) < 176.25:
			offset_x = 16
		
		_ when abs(velocity.x) < 414.84375 and abs(velocity.x) >= 176.25:
			offset_x = 19
		
		_ when abs(velocity.x) < 466.640625 and abs(velocity.x) >= 414.84375:
			offset_x = 23
		
		_ when abs(velocity.x) < 518.4375 and abs(velocity.x) >= 466.640625:
			offset_x = 24
		
		_ when abs(velocity.x) < 570.46875 and abs(velocity.x) >= 518.4375:
			offset_x = 25
		
		_ when abs(velocity.x) >= 570.46875:
			offset_x = 26
	
	position.x = clampf(position.x, camera.limit_left + offset_x, camera.limit_right - offset_x)
	position.y = clampf(position.y, camera.limit_top - OFFSET_TOP, camera.limit_bottom + OFFSET_BOT)
	
	if current_state == MainState.WALKING or\
	current_state == MainState.DASHING or\
	current_state == MainState.WALL_SLIDING:
		position = position.snappedf(UNIT)
	else:
		position = position.round()
		## Q: Why not just round position always?
		## A: Because it breaks wall sliding and makes movement down slopes less smooth.


func animate()->void:
	if direction == 1:
		sprite.flip_h = false
		sprite.offset.x = -3
	else:
		sprite.flip_h = true
		sprite.offset.x = 3
	
	if current_state == MainState.JUMPING or current_state == MainState.FALLING:
		sprite.offset.y = -8
	else:
		sprite.offset.y = -15
	
	if current_state == MainState.DASHING:
		sprite.play("dash")
	elif current_state == MainState.JUMPING or current_state == MainState.FALLING:
		sprite.play("jump")
	else:
		sprite.play("idle")
	
	# Flicker sprite during i-frames
	if !i_frame_timer.is_stopped():
		i_frames_left -= 1
		# Show on even frames; hide on odd frames.
		if i_frames_left % 2 == 0:
			sprite.show()
		else:
			sprite.hide()
	else:
		i_frames_left = i_frames_total
		sprite.show()


func shoot()->void:
	if direction == 1:
		if current_state == MainState.DASHING:
			buster_spawn.position = Vector2(60, 8)
		elif current_state == MainState.WALL_SLIDING:
			buster_spawn.position = Vector2(-40, -5)
		else:
			buster_spawn.position = Vector2(40, -5)
	else:
		if current_state == MainState.DASHING:
			buster_spawn.position = Vector2(-60, 8)
		elif current_state == MainState.WALL_SLIDING:
			buster_spawn.position = Vector2(40, -5)
		else:
			buster_spawn.position = Vector2(-40, -5)
	
	if Input.is_action_just_pressed("shoot_primary"):
		var new_lemon: HitBox2D = lemon.instantiate()
		#get_tree().current_scene.add_child(new_lemon)
		get_tree().current_scene.get_child(6).get_child(0).get_child(0).add_child(new_lemon)
		new_lemon.global_position = buster_spawn.global_position
		new_lemon.max_speed = new_lemon.BASE_MAX_SPEED * stats.buster_shot_speed_mult
		new_lemon.acceleration = new_lemon.BASE_ACCELERATION * stats.buster_shot_speed_mult
		
		if current_state == MainState.DASHING or dashing_to_airborne:
			new_lemon.speed = new_lemon.BASE_MAX_SPEED * stats.buster_shot_speed_mult
		else:
			new_lemon.initial_speed = new_lemon.BASE_INITIAL_SPEED * stats.buster_shot_speed_mult
			new_lemon.speed = new_lemon.initial_speed
		
		if current_state == MainState.WALL_SLIDING:
			new_lemon.direction = -direction
		else:
			new_lemon.direction = direction
		
		new_lemon.top_level = true
