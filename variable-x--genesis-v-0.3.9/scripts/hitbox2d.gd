# Stolen from GodotGameLab: https://www.youtube.com/watch?v=imMwkEiFix4
# Stolen from Michael Games: https://www.youtube.com/watch?v=QVFUjqSuFrg
class_name HitBox2D extends Area2D


@export var identifier: String = "DUMMY"
@export_flags("Fire", "Ice", "Elec") var type: int = 0

## If enabled, this HitBox2D will only make contact with the first HurtBox2D it encounters.
## Otherwise, it will register collisions with any HurtBox2D it encounters.
@export var one_shot: bool = false

## If enabled, this HitBox2D will register a collision with a HurtBox2D on every physics tick.
@export var continuous: bool = false

var _has_hit: bool = false
var current_hurtbox: HurtBox2D


func _init()->void:
	monitoring = true
	monitorable = false
	area_entered.connect(_on_area_entered)


func reset()->void:
	_has_hit = false


func _on_area_entered(hurtbox: Area2D)->void:
	if hurtbox is HurtBox2D:
		current_hurtbox = hurtbox
		var already_hit: bool = one_shot and _has_hit
		
		if already_hit or hurtbox.is_invincible:
			return
		
		_has_hit = true
		
		#prints("%s hit %s at position %s" % [self, hurtbox, hurtbox.global_position])
		hurtbox.take_damage(self)
		hurtbox.flash_briefly()


func _physics_process(_delta: float)->void:
	if continuous and current_hurtbox != null:
		if overlaps_area(current_hurtbox):
			current_hurtbox.flash_briefly()


func activate(duration: float = INF)->void:
	set_active(true)
	if duration != INF:
		await get_tree().create_timer(duration).timeout
		set_active(false)


func set_active(value: bool = true)->void:
	set_deferred("monitoring", value)


func set_active_continuous()->void:
	# This instantly disables and re-enables the hitbox so it can hit the same hurtbox repeatedly.
	self.set_active(false)
	self.set_active(true)
