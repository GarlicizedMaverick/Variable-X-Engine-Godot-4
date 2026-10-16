@abstract
class_name BaseEnemy extends CharacterBody2D


@export var definition: EnemyDefinition


func _ready()->void:
	add_to_group("Enemies")
