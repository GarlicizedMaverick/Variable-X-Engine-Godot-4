@abstract
class_name BaseEnemy extends CharacterBody2D


signal health_depleted
signal health_changed

@export var definition: EnemyDefinition
@export var max_health: float

var health: float = 0: set = _on_health_set


func _init()->void:
	setup_stats.call_deferred()
	add_to_group("Enemies")


func setup_stats()->void:
	# Recalculate the current stats first
	health = max_health


func _on_health_set(new_value: float)->void:
	health = clampf(new_value, 0, max_health)
	health_changed.emit()
	if health <= 0:
		health_depleted.emit()
