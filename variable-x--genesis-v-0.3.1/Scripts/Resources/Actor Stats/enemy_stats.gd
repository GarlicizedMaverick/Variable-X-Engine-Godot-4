# Stolen from Queble
# https://www.youtube.com/watch?v=vsBb9921GfA
class_name EnemyStats extends Resource


signal health_depleted
signal health_changed(current_health: float, max_health: float)


@export var max_health: float = 16

#@export_group("X Weaknesses")
#@export var weak_to_shotgun_ice: bool = false
#@export var weak_to_electric_spark: bool = false
#@export var weak_to_rolling_shield: bool = false
#@export var weak_to_homing_torpedo: bool = false
#@export var weak_to_boomerang_cutter: bool = false
#@export var weak_to_chameleon_sting: bool = false
#@export var weak_to_storm_tornado: bool = false
#@export var weak_to_fire_wave: bool = false

#@export_group("EP Weaknesses")
#@export var weak_to_rolling_cutter: bool = false
#@export var weak_to_elec_beam: bool = false
#@export var weak_to_ice_slasher: bool = false
#@export var weak_to_fire_storm: bool = false
#@export var weak_to_hyper_bomb: bool = false
#@export var weak_to_guts_arm: bool = false
#@export var weak_to_bubble_lead: bool = false
#@export var weak_to_atomic_fire: bool = false
#@export var weak_to_leaf_shield: bool = false
#@export var weak_to_air_shooter: bool = false
#@export var weak_to_crash_bomber: bool = false
#@export var susceptible_to_time_stopper: bool = false
#@export var weak_to_quick_boomerang: bool = false
#@export var weak_to_metal_blade: bool = false
#@export var weak_to_top_spin: bool = false
#@export var weak_to_shadow_blade: bool = false
#@export var weak_to_spark_shock: bool = false
#@export var weak_to_magnet_missile: bool = false
#@export var weak_to_hard_knuckle: bool = false
#@export var weak_to_gemini_laser: bool = false
#@export var weak_to_needle_cannon: bool = false
#@export var weak_to_search_snake: bool = false

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
