# Stolen from GodotGameLab: https://www.youtube.com/watch?v=imMwkEiFix4
# Stolen from Michael Games: https://www.youtube.com/watch?v=QVFUjqSuFrg
class_name HitBox2D extends Area2D


@export var identifier: String = "DUMMY"
@export_flags("Fire", "Ice", "Elec") var type: int = 0
@export var damage: float = 1
@export var one_shot: bool = false

var _has_hit: bool = false


func _init()->void:
	monitoring = true
	monitorable = false
	area_entered.connect(_on_area_entered)


func reset()->void:
	_has_hit = false


func _on_area_entered(hurtbox: Area2D)->void:
	if hurtbox is HurtBox2D:
		var already_hit: bool = one_shot and _has_hit
		
		if already_hit or hurtbox.is_invincible:
			return
		
		_has_hit = true
		#prints("%s hit %s at position %s" % [self, hurtbox, hurtbox.global_position])
		hurtbox.take_damage(self)


func activate(duration: float = INF)->void:
	set_active(true)
	if duration != INF:
		await get_tree().create_timer(duration).timeout
		set_active(false)


func set_active(value: bool = true)->void:
	monitoring = value
