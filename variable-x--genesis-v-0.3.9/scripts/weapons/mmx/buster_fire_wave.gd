class_name BusterFireWave extends HitBox2D


@onready var sprite: AnimatedSprite2D = $Sprite
@onready var spawn_timer: Timer = $SpawnTimer

const SPEED: int = 840 # SNES-accurate

var direction: int


func _ready()->void:
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	sprite.frame = 0
	sprite.play("default")


func _on_spawn_timer_timeout()->void:
	queue_free()


func _physics_process(delta: float)->void:
	position.x += SPEED * direction * delta
