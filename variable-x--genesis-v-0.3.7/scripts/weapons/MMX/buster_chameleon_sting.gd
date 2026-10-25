class_name BusterChameleonSting extends HitBox2D


@onready var sprite_prong: Sprite2D = $SpriteProng
@onready var sprite_flash: AnimatedSprite2D = $SpriteFlash
@onready var screen_notif: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
@onready var spawn_timer: Timer = $SpawnTimer
@onready var flash_timer: Timer = $FlashTimer

const BASE_SPEED: int = 720 # SNES-accurate

var speed: float
var direction: int
var angle: Vector2

var angle_straight: Vector2 = Vector2.RIGHT

var angle_up_low: Vector2 = Vector2.from_angle(-PI/8)
var angle_up_high: Vector2 = Vector2.from_angle(-PI/4)

var angle_down_high: Vector2 = Vector2.from_angle(PI/8)
var angle_down_low: Vector2 = Vector2.from_angle(PI/4)

var current_state: MainState
enum MainState
{
	SPAWNING = 0,
	FLASHING,
	SPLITTING
}

var prong_type: ProngType
enum ProngType
{
	INITIAL = 0,
	SPLIT
}

var angle_type: AngleType
enum AngleType
{
	STRAIGHT = 0,
	UPWARD,
	DOWNWARD
}

var player: Player


func _ready()->void:
	player = get_parent()
	screen_notif.screen_exited.connect(_on_screen_exited)
	
	if prong_type == ProngType.INITIAL:
		speed = BASE_SPEED
		spawn_timer.timeout.connect(_on_spawn_timer_timeout)
		flash_timer.timeout.connect(_on_flash_timer_timeout)
		sprite_prong.show()
		sprite_flash.hide()
	else:
		speed = BASE_SPEED * player.stats.buster_shot_speed_mult
		sprite_prong.hide()
		sprite_flash.hide()
		await get_tree().physics_frame
		await get_tree().physics_frame
		await get_tree().physics_frame
		sprite_prong.show()


func _on_screen_exited()->void:
	queue_free()


func _on_spawn_timer_timeout()->void:
	if prong_type == ProngType.INITIAL:
		sprite_prong.hide()
		sprite_flash.show()
		sprite_flash.play("default")
		current_state = MainState.FLASHING
		flash_timer.start()


func _on_flash_timer_timeout()->void:
	if prong_type == ProngType.INITIAL:
		var split_a: BusterChameleonSting = self.duplicate()
		var split_b: BusterChameleonSting = self.duplicate()
		var split_c: BusterChameleonSting = self.duplicate()
		
		split_a.prong_type = ProngType.SPLIT
		split_b.prong_type = ProngType.SPLIT
		split_c.prong_type = ProngType.SPLIT
		
		self.add_sibling(split_a)
		self.add_sibling(split_b)
		self.add_sibling(split_c)
		
		split_a.top_level = true
		split_b.top_level = true
		split_c.top_level = true
		
		split_a.global_position = self.global_position
		split_b.global_position = self.global_position
		split_c.global_position = self.global_position
		
		split_a.angle_type = self.angle_type
		split_b.angle_type = self.angle_type
		split_c.angle_type = self.angle_type
		
		split_a.direction = self.direction
		split_b.direction = self.direction
		split_c.direction = self.direction
		
		# Top projectile
		match split_a.angle_type:
			AngleType.STRAIGHT:
				split_a.angle = angle_up_low
			
			AngleType.UPWARD:
				split_a.angle = angle_up_high
			
			AngleType.DOWNWARD:
				split_a.angle = angle_straight
		
		# Middle projectile
		match split_b.angle_type:
			AngleType.STRAIGHT:
				split_b.angle = angle_straight
			
			AngleType.UPWARD:
				split_b.angle = angle_up_low
			
			AngleType.DOWNWARD:
				split_b.angle = angle_down_high
		
		# Bottom projectile
		match split_c.angle_type:
			AngleType.STRAIGHT:
				split_c.angle = angle_down_high
			
			AngleType.UPWARD:
				split_c.angle = angle_straight
			
			AngleType.DOWNWARD:
				split_c.angle = angle_down_low
		
		if direction == 1:
			split_a.rotation = split_a.angle.angle()
			split_b.rotation = split_b.angle.angle()
			split_c.rotation = split_c.angle.angle()
		else:
			split_a.rotation = -split_a.angle.angle()
			split_b.rotation = -split_b.angle.angle()
			split_c.rotation = -split_c.angle.angle()
		
		split_a.current_state = MainState.SPLITTING
		split_b.current_state = MainState.SPLITTING
		split_c.current_state = MainState.SPLITTING
		
		self.queue_free()


func _physics_process(delta: float)->void:
	handle_state_machine(delta)


func handle_state_machine(delta: float)->void:
	match current_state:
		MainState.SPAWNING:
			global_position.x += direction * speed * delta
		
		MainState.FLASHING:
			pass
		
		MainState.SPLITTING:
			global_position.x += angle.x * direction * speed * delta
			global_position.y += angle.y * speed * delta
