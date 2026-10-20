class_name BusterElectricSparkBallH1 extends HitBox2D


@onready var sprite: AnimatedSprite2D = $Sprite
@onready var screen_notif: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
@onready var wall_detector: Area2D = $WallDetector

@export var spark_ball_v: PackedScene

const BASE_SPEED: int = 450 # 360 if truly SNES-accurate

var speed: float
var direction: int


func _ready()->void:
	sprite.play("default")
	screen_notif.screen_exited.connect(_on_screen_exited)


func _physics_process(delta: float)->void:
	position += transform.x * speed * direction * delta
	collide(delta)


func _on_screen_exited()->void:
	queue_free()


func collide(delta: float)->void:
	# The projectile spawns two vertical sparkballs then deletes itself.
	if wall_detector.has_overlapping_bodies() or self.has_overlapping_areas():
		speed = 0
		sprite.play("hit")
		# Stall for nine frames before spawning the other sparkballs.
		await get_tree().create_timer(0.15, true, true).timeout
		sprite.hide()
		
		var new_sparkball_v_up: HitBox2D = spark_ball_v.instantiate()
		var new_sparkball_v_down: HitBox2D = spark_ball_v.instantiate()
		
		new_sparkball_v_up.direction = -1
		new_sparkball_v_down.direction = 1
		
		self.add_sibling(new_sparkball_v_up)
		self.add_sibling(new_sparkball_v_down)
		
		new_sparkball_v_up.top_level = true
		new_sparkball_v_down.top_level = true
		
		new_sparkball_v_up.global_position = global_position
		new_sparkball_v_down.global_position = global_position
		
		# Disable collision checking for the first few frames of their existences.
		const INITIAL_DISABLE_TIME: int = 3
		new_sparkball_v_up.collision_enabler_timer = delta * INITIAL_DISABLE_TIME
		new_sparkball_v_down.collision_enabler_timer = delta * INITIAL_DISABLE_TIME
		
		queue_free()
