# Stolen from Queble (https://www.youtube.com/watch?v=vsBb9921GfA)
class_name EnemyStats extends Resource


signal health_depleted
signal health_changed(current_health: float, max_health: float)


@export var max_health: float = 16


var health: float = 0: set = _on_health_set


func _init()->void:
	setup_stats.call_deferred()


func setup_stats()->void:
	# Recalculate the current stats first
	health = max_health


func _on_health_set(new_value: float)->void:
	health = clampf(new_value, 0, max_health)
	health_changed.emit(health, max_health)
	if health <= 0:
		health_depleted.emit()
