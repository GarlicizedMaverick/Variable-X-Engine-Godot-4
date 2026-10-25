# Partially stolen from u/Anonzs (https://www.reddit.com/user/Anonzs/)
# (https://www.reddit.com/r/godot/comments/1aj5v1s/help_straight_movement_into_circular_movement/)
class_name BusterBoomerangCutter extends HitBox2D


@onready var sprite: Sprite2D = $Sprite
@onready var screen_notif: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
@onready var grab_timer: Timer = $GrabTimer

const BASE_INITIAL_HSPEED: int = 675 # 540 if SNES-accurate
const MAXIMUM_DISTANCE_X: int = 96

const ROTATION_SPEED_NORMAL: float = PI/6.0
const ROTATION_SPEED_STOPPED: float = PI/4.0
const ROTATION_SPEED_BEELINE: float = PI/3.0

const BASE_RADIUS: int = 112

var direction: Vector2
var initial_direction: Vector2
var initial_hspeed: float
var speed: float
var initial_position_x: float

var path_center: Vector2
var radius: int = BASE_RADIUS

var player: Player
var player_position_when_beginning_beeline: Vector2

var boomerang_type: BoomerangType
enum BoomerangType
{
	UPWARD = 0,
	DOWNWARD,
}

var current_state: MainState
enum MainState
{
	INITIAL_STRAIGHT_SHOT = 0,
	TURNING,
	FROZEN,
	BEELINE_TO_PLAYER
}


func _ready()->void:
	player = self.get_parent()
	screen_notif.screen_exited.connect(_on_screen_exited)
	self.body_entered.connect(_on_body_entered)
	current_state = MainState.INITIAL_STRAIGHT_SHOT
	
	if Input.is_action_pressed("dpad_down"):
		boomerang_type = BoomerangType.DOWNWARD
	else:
		boomerang_type = BoomerangType.UPWARD


func _on_screen_exited()->void:
	queue_free()


func _on_body_entered(body: Node2D)->void:
	if body is Player and\
	((current_state == MainState.TURNING and grab_timer.is_stopped)\
	or current_state == MainState.BEELINE_TO_PLAYER):
		if not _has_hit:
			# Refill ammo once I implement it.
			pass
		
		queue_free()


func _physics_process(delta: float)->void:
	update_state_machine(delta)
	
	if Input.is_action_pressed("dpad_up"):
		current_state = MainState.FROZEN


func update_state_machine(delta: float)->void:
	match current_state:
		MainState.INITIAL_STRAIGHT_SHOT:
			sprite.rotation += ROTATION_SPEED_NORMAL
			global_position.x += initial_hspeed * initial_direction.x * delta
			
			# Transition Logic
			if initial_direction == Vector2.RIGHT:
				if global_position.x >= initial_position_x + MAXIMUM_DISTANCE_X:
					if boomerang_type == BoomerangType.UPWARD:
						path_center = Vector2(global_position.x, global_position.y - BASE_RADIUS)
					else:
						path_center = Vector2(global_position.x, global_position.y + BASE_RADIUS)
					grab_timer.start()
					current_state = MainState.TURNING
			else:
				if global_position.x <= initial_position_x - MAXIMUM_DISTANCE_X:
					if boomerang_type == BoomerangType.UPWARD:
						path_center = Vector2(global_position.x, global_position.y - BASE_RADIUS)
					else:
						path_center = Vector2(global_position.x, global_position.y + BASE_RADIUS)
					grab_timer.start()
					current_state = MainState.TURNING
		
		MainState.TURNING:
			sprite.rotation += ROTATION_SPEED_NORMAL
			
			direction = path_center.direction_to(global_position)
			orbit()
			follow_player(delta)
			global_position += speed * direction * delta
			
			# No Transition Logic...
		
		MainState.FROZEN:
			sprite.rotation += ROTATION_SPEED_STOPPED
			
			# Transition Logic
			if Input.is_action_just_released("dpad_up"):
				# This is so X picks up the projectile even if it was already touching him.
				# "body_entered" would be ignored otherwise.
				self.set_active_continuous()
				player_position_when_beginning_beeline = player.global_position
				const BEELINE_SPEED: int = 960
				speed = BEELINE_SPEED * player.stats.buster_shot_speed_mult
				direction = global_position.direction_to(player_position_when_beginning_beeline)
				current_state = MainState.BEELINE_TO_PLAYER
		
		MainState.BEELINE_TO_PLAYER:
			sprite.rotation += ROTATION_SPEED_BEELINE
			global_position += speed * direction * delta


func orbit()->void:
	var distance_to: float = path_center.distance_to(global_position)
	var clockwise: bool
	if (boomerang_type == BoomerangType.UPWARD and initial_direction == Vector2.LEFT) or\
	(boomerang_type == BoomerangType.DOWNWARD and initial_direction == Vector2.RIGHT):
		clockwise = true
	else:
		clockwise = false
	
	if distance_to >= radius:
		if !clockwise:
			direction = direction.normalized().orthogonal()
		
		else:
			direction = -direction.normalized().orthogonal()


func follow_player(_delta: float)->void:
	const FOLLOW_SPEED: int = 1080
	
	if initial_direction == Vector2.RIGHT:
		if player.global_position.x < path_center.x and\
		player.global_position.x > path_center.x - (2 * MAXIMUM_DISTANCE_X):
			# Not too far
			speed = initial_hspeed
		
		else:
			# Too far
			speed = FOLLOW_SPEED
			path_center.x = player.global_position.x
	else:
		if player.global_position.x > path_center.x and\
		player.global_position.x < path_center.x + (2 * MAXIMUM_DISTANCE_X):
			# Not too far
			speed = initial_hspeed
		
		else:
			# Too far
			speed = FOLLOW_SPEED
			path_center.x = player.global_position.x
