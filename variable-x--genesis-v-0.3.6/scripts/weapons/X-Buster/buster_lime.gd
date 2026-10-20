class_name BusterLime extends HitBox2D


@onready var sprite: AnimatedSprite2D = $Sprite
@onready var screen_notif: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
@onready var wall_detector: Area2D = $WallDetector

const BASE_SPEED: int = 900 # 720 if truly SNES-accurate

var speed: float
var direction: int
var player: Player


func _ready()->void:
	player = self.get_parent()
	screen_notif.screen_exited.connect(_on_screen_exited)
	sprite.play("spawn")
	await get_tree().physics_frame
	sprite.play("default")


func _on_screen_exited()->void:
	queue_free()


func _physics_process(delta: float)->void:
	position += transform.x * speed * direction * delta
	collide()


func collide()->void:
	if wall_detector.has_overlapping_bodies():
		queue_free()


func _on_area_entered(hurtbox: Area2D)->void:
	var enemy_hp: float = hurtbox.get_parent().health
	var enemy_lime_damage: float = hurtbox.get_parent().damage_table.damage_table.get("Lime")
	
	# Destroy the lime if the enemy won't die from it, otherwise keep it going.
	# That functionality is why I have to manually call this function...
	# Although, maybe I can make another property. "pierce_if_kills"? Maybe...
	if enemy_hp > enemy_lime_damage * player.stats.attack_power:
		hurtbox.take_damage(self)
		queue_free()
	else:
		hurtbox.take_damage(self)
