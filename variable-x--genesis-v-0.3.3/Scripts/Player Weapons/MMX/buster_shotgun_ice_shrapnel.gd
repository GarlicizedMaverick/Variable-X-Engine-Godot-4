class_name BusterShotgunIceShrapnel extends HitBox2D


@onready var sprite: Sprite2D = $Sprite
@onready var screen_notif: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D

const SPEED: int = 1350 # 9 p/f * 320/256

var direction: int
var angle: Vector2

var angle_a: Vector2 = Vector2.from_angle(-PI/4)
var angle_b: Vector2 = Vector2.from_angle(-PI/7)
var angle_c: Vector2 = Vector2.RIGHT
var angle_d: Vector2 = Vector2.from_angle(PI/7)
var angle_e: Vector2 = Vector2.from_angle(PI/4)

var collision_enabler_frame_timer: int


func _ready()->void:
	set_collision_mask_value(4, false)
	screen_notif.screen_exited.connect(_on_screen_exited)


func _physics_process(delta: float)->void:
	collision_enabler_frame_timer -= 1
	position.x += angle.x * direction * SPEED * delta
	position.y += angle.y * SPEED * delta
	
	if collision_enabler_frame_timer <= 0:
		collide()


func _on_screen_exited()->void:
	queue_free()


func collide()->void:
	set_collision_mask_value(4, true)
	if self.has_overlapping_areas():
		queue_free()
