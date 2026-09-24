class_name DummyEnemy extends CharacterBody2D


@export var stats: EnemyStats


#func _physics_process(_delta: float) -> void:
	#velocity = Vector2(-240,0)
	#move_and_slide()
	#pass
