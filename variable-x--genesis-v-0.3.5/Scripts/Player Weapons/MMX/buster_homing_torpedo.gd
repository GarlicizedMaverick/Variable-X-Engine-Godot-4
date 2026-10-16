# Stolen from pleasedontjudgeme
# https://forum.godotengine.org/t/how-to-make-homing-bullet-detect-new-target/115476/8
class_name BusterHomingTorpedo extends HitBox2D


@onready var sprite: Sprite2D = $Sprite
@onready var screen_notif: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
@onready var do_not_seek_yet_timer: Timer = $DoNotSeekYetTimer

const BASE_INITIAL_SPEED: float = 168.75 # 135 if SNES-accurate
const MAX_SPEED: float = 900 # 720 if SNES-accurate
const LATERAL_ACCELERATION: float = 1125 # 900 if SNES-accurate

var initial_direction: Vector2
var direction: float

var speed: float
var steer_acceleration: Vector2 = Vector2.ZERO
var steer_force: float = 600
var velocity: Vector2 = Vector2.ZERO

var target: Node2D = null
var targets: Array[Node2D] = []
var never_had_a_target: bool = true


func _ready()->void:
	screen_notif.screen_exited.connect(_on_screen_exited)
	direction = initial_direction.angle()
	sprite.rotation_degrees = 90


func _on_screen_exited()->void:
	queue_free()


func seek()->Vector2:
	var steer: Vector2 = Vector2.ZERO
	# The target has been freed or is null
	if !is_instance_valid(target):
		target = get_nearest_enemy()
	if target:
		var desired: Vector2 = (target.position - position).normalized() * speed
		steer = (desired - velocity).normalized() * steer_force
	else:
		steer = transform.x * speed
	return steer


func _physics_process(delta: float)->void:
	sprite.global_position = global_position
	if target != null:
		never_had_a_target = false
	if not is_instance_valid(target):
		if never_had_a_target:
			velocity = speed * initial_direction
		else:
			velocity += steer_acceleration * delta
	collide()
	accelerate(delta)
	target = get_nearest_enemy()
	if do_not_seek_yet_timer.is_stopped():
		steer_acceleration += seek()
	velocity += steer_acceleration * delta
	velocity = velocity.limit_length(speed)
	rotation = velocity.angle()
	
	position += velocity * delta


func collide()->void:
	if self.has_overlapping_areas():
		queue_free()


func accelerate(delta: float)->void:
	speed += LATERAL_ACCELERATION * delta
	speed = clampf(speed, BASE_INITIAL_SPEED, MAX_SPEED)


func get_nearest_enemy()->Node2D:
	var nearest: Node2D = null
	var min_dist: float = INF
	var pos: Vector2 = global_position
	
	for enemy: Node in get_tree().get_nodes_in_group("Enemies"):
		if not enemy is Node2D:
			continue
	
		var dist: float = pos.distance_to(enemy.global_position)
		if dist < min_dist:
			min_dist = dist
			nearest = enemy
	return nearest 
