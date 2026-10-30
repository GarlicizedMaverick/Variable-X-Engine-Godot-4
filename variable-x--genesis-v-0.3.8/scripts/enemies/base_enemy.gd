@abstract
class_name BaseEnemy extends CharacterBody2D


signal health_depleted
signal health_changed

@onready var player: Player = $"../../../../../../EntityRoot/Player"

@export var max_health: float
@export var initial_direction: InitialDirection = InitialDirection.TOWARD_PLAYER

var health: float = 0: set = _on_health_set

const LEFT_OF_PLAYER: String = "Left of Player"
const RIGHT_OF_PLAYER: String = "Right of Player"
enum InitialDirection
{
	LEFT = 0,
	RIGHT,
	TOWARD_PLAYER,
	AWAY_FROM_PLAYER
}
var direction: int


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


func set_initial_direction()->void:
	match initial_direction:
		InitialDirection.LEFT:
			direction = -1
		InitialDirection.RIGHT:
			direction = 1
		InitialDirection.TOWARD_PLAYER:
			if get_position_relative_to_player() == LEFT_OF_PLAYER:
				direction = 1
			else:
				direction = -1
		InitialDirection.AWAY_FROM_PLAYER:
			if get_position_relative_to_player() == LEFT_OF_PLAYER:
				direction = -1
			else:
				direction = 1


func get_position_relative_to_player()->String:
	if global_position.x < player.global_position.x:
		return LEFT_OF_PLAYER
	else:
		return RIGHT_OF_PLAYER
