class_name BusterBlueberry extends HitBox2D


@onready var sprite: AnimatedSprite2D = $Sprite
@onready var screen_notif: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
@onready var wall_detector: Area2D = $WallDetector

const BASE_SPEED: int = 1200 # 960 if truly SNES-accurate

var speed: float
var direction: int


func _ready()->void:
	screen_notif.screen_exited.connect(_on_screen_exited)


func _on_screen_exited()->void:
	queue_free()


func _physics_process(delta: float)->void:
	position += transform.x * speed * direction * delta
	collide()


func collide()->void:
	if wall_detector.has_overlapping_bodies():
		queue_free()


func _on_area_entered(hurtbox: Area2D)->void:
	var enemy_hp: float = hurtbox.get_parent().stats.health
	var enemy_lime_damage: float = hurtbox.get_parent().damage_table.damage_table.get("Blueberry")
	
	if enemy_hp > enemy_lime_damage:
		hurtbox.take_damage(self)
		queue_free()
	else:
		hurtbox.take_damage(self)
