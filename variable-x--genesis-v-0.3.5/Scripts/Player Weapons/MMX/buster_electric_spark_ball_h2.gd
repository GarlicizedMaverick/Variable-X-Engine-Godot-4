class_name BusterElectricSparkBallH2 extends HitBox2D


@onready var sprite: AnimatedSprite2D = $Sprite
@onready var screen_notif: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D

const BASE_SPEED: int = 540 # Not affected by X's buster_shot_speed_mult

var speed: float
var direction: int
var collision_enabler_timer: float


func _ready()->void:
	speed = BASE_SPEED
	sprite.play("default")
	set_collision_mask_value(4, false)
	screen_notif.screen_exited.connect(_on_screen_exited)


func _physics_process(delta: float)->void:
	collision_enabler_timer -= delta
	position += transform.x * speed * direction * delta
	if collision_enabler_timer <= 0:
		collide()


func _on_screen_exited()->void:
	queue_free()


func collide()->void:
	# The projectile plays its hit animation, then returns to its normal animation.
	# Hitting an enemy doesn't destroy the Electric Spark at this stage.
	set_collision_mask_value(4, true)
	if self.has_overlapping_areas():
		sprite.play("hit")
		await get_tree().create_timer(0.15, true, true).timeout
		sprite.play("default")
