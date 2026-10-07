class_name DummyEnemy extends CharacterBody2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var hurtbox: HurtBox2D = $HurtBox2D
@onready var player: Player = $"../../Player"

@export var stats: EnemyStats
@export var damage_table: MMXEnemyDamageTable


func _ready()->void:
	stats.health = stats.max_health
	stats.health_depleted.connect(_on_health_depleted)


#func _physics_process(_delta: float) -> void:
	#velocity = Vector2(-240,0)
	#move_and_slide()
	#pass


func _on_damage_taken(hitbox: HitBox2D) -> void:
	var id: String = hitbox.identifier
	var damage: float = damage_table.damage_table.get(id)
	
	if id == "Hadouken Weak" or id == "Hadouken" or id == "Pseudoken":
		# Player attack power doesn't affect the Hadoukens
		stats.health -= damage
	else:
		stats.health -= damage * player.stats.attack_power
	
	change_color()


func _on_health_depleted()->void:
	self.queue_free()


func change_color()->void:
	sprite.modulate = Color(1, 0.125 * stats.health, 0.25 * stats.health, 1)
