# SNES-accurate proportions/timings; NOT SNES-accurate speeds!
# I increased the speed and acceleration values by 320/256 (5/4)...
# ...because of the increased screen width, so that shots spend the same amount of time on screen.
class_name BusterLemon extends HitBox2D


const BASE_INITIAL_SPEED: int = 600 # 480 if truly SNES-accurate
const BASE_MAX_SPEED: int = 900 # 720 if truly SNES-accurate
const BASE_ACCELERATION: float = 2250 # 1800 if truly SNES-accurate

var speed: float
var initial_speed: float
var max_speed: float
var acceleration: float
var direction: int


func _physics_process(delta: float)->void:
	if speed < max_speed: 
		accelerate(delta)
	
	speed = clampf(speed, initial_speed, max_speed)
	position += transform.x * speed * direction * delta


func accelerate(delta: float)->void:
	speed += acceleration * delta


func _on_screen_exited()->void:
	queue_free()
