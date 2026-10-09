class_name BusterElectricSparkBallV extends HitBox2D


@onready var sprite: AnimatedSprite2D = $Sprite
@onready var screen_notif: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
@onready var wall_detector: Area2D = $WallDetector

@export var spark_ball_h2: PackedScene

const BASE_SPEED: int = 1080 # Not affected by X's buster_shot_speed_mult

var speed: float
var direction: int
var collision_enabler_timer: float


func _ready()->void:
	speed = BASE_SPEED
	sprite.play("default")
	wall_detector.set_collision_mask_value(4, false)
	screen_notif.screen_exited.connect(_on_screen_exited)


func _physics_process(delta: float)->void:
	collision_enabler_timer -= delta
	position += transform.y * speed * direction * delta
	# Disables all collision detection until a few frames after being spawned.
	if collision_enabler_timer <= 0:
		collide(delta)


func _on_screen_exited()->void:
	queue_free()


func collide(delta: float)->void:
	# The projectile spawns two horizontal sparkballs then deletes itself.
	wall_detector.set_collision_mask_value(4, true)
	if wall_detector.has_overlapping_bodies() or self.has_overlapping_areas():
		speed = 0
		sprite.play("hit")
		# Stall for nine frames before spawning the other sparkballs.
		await get_tree().create_timer(0.15, true, true).timeout
		sprite.hide()
		
		var new_sparkball_h2_left: HitBox2D = spark_ball_h2.instantiate()
		var new_sparkball_h2_right: HitBox2D = spark_ball_h2.instantiate()
		
		new_sparkball_h2_left.direction = -1
		new_sparkball_h2_right.direction = 1
		
		self.add_sibling(new_sparkball_h2_left)
		self.add_sibling(new_sparkball_h2_right)
		
		new_sparkball_h2_left.top_level = true
		new_sparkball_h2_right.top_level = true
		
		new_sparkball_h2_left.global_position = global_position
		new_sparkball_h2_right.global_position = global_position
		
		# Disable collision checking for the first few frames of their existences.
		const INITIAL_DISABLE_TIME: int = 1
		new_sparkball_h2_left.collision_enabler_timer = delta * INITIAL_DISABLE_TIME
		new_sparkball_h2_right.collision_enabler_timer = delta * INITIAL_DISABLE_TIME
		
		queue_free()
