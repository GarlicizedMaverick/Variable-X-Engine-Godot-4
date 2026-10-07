class_name BusterDashLemon extends HitBox2D


@onready var screen_notif: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
@onready var wall_detector: Area2D = $WallDetector

const BASE_SPEED: int = 900 # 720 if truly SNES-accurate

var speed: float
var direction: int


func _ready()->void:
	screen_notif.screen_exited.connect(_on_screen_exited)


func _physics_process(delta: float)->void:
	position += transform.x * speed * direction * delta
	collide()


func _on_screen_exited()->void:
	queue_free()


func collide()->void:
	if wall_detector.has_overlapping_bodies() or self.has_overlapping_areas():
		queue_free()
