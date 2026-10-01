# Stolen from GodotGameLab: https://www.youtube.com/watch?v=imMwkEiFix4
# Stolen from Michael Games: https://www.youtube.com/watch?v=QVFUjqSuFrg
class_name HurtBox2D extends Area2D


signal damage_taken(hitbox: HitBox2D)

@export var identifier: String = "DUMMY"
@export var is_invincible: bool = false


func _init()->void:
	monitoring = false
	monitorable = true


func take_damage(hitbox: HitBox2D)->void:
	damage_taken.emit(hitbox)


func set_invincibility_period(duration: float = 1.5)->void:
	set_deferred("monitorable", false)
	is_invincible = true
	await  get_tree().create_timer(duration).timeout
	set_deferred("monitorable", true)
	is_invincible = false
