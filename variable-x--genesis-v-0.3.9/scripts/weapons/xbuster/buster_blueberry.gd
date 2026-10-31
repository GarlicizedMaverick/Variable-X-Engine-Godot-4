class_name BusterBlueberry extends HitBox2D


@onready var sprite: AnimatedSprite2D = $Sprite
@onready var screen_notif: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
@onready var wall_detector: Area2D = $WallDetector
@onready var flip_v_timer: Timer = $FlipVTimer

const BASE_SPEED: int = 1200 # 960 if truly SNES-accurate

var speed: float
var direction: int
var player: Player


func _ready()->void:
	screen_notif.screen_exited.connect(_on_screen_exited)
	flip_v_timer.timeout.connect(_on_flip_v_timer_timeout)
	player = self.get_parent()


func _on_screen_exited()->void:
	queue_free()


func _on_flip_v_timer_timeout()->void:
	if sprite.flip_v == true:
		sprite.flip_v = false
	else:
		sprite.flip_v = true


func _physics_process(delta: float)->void:
	position += transform.x * speed * direction * delta
	collide()


func collide()->void:
	if wall_detector.has_overlapping_bodies():
		queue_free()


func _on_area_entered(hurtbox: Area2D)->void:
	var enemy_hp: float = hurtbox.get_parent().health
	var enemy_blueberry_damage: float =\
	hurtbox.get_parent().damage_table.damage_table.get("Blueberry")
	
	if enemy_hp > enemy_blueberry_damage * player.stats.attack_power:
		hurtbox.take_damage(self)
		queue_free()
	else:
		hurtbox.take_damage(self)
