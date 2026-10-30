class_name DummyEnemy extends BaseEnemy


@onready var sprite: Sprite2D = $Sprite2D
@onready var hurtbox: HurtBox2D = $HurtBox2D

@export var damage_table: MMXEnemyDamageTable


func _ready()->void:
	health_depleted.connect(_on_health_depleted)


#func _physics_process(_delta: float)->void:
	#velocity = Vector2(-240,0)
	#move_and_slide()
	#pass


func _on_damage_taken(hitbox: HitBox2D)->void:
	var id: String = hitbox.identifier
	var damage: float = damage_table.damage_table.get(id)
	
	if id == "Hadouken Weak" or id == "Hadouken" or id == "Pseudoken":
		# Player attack power doesn't affect the Hadoukens
		health -= damage
	else:
		if hitbox.continuous == true:
			var delta: float = (1.0/Engine.physics_ticks_per_second)
			health -= damage * player.stats.attack_power * delta
			hitbox.set_active_continuous()
			
		else:
			health -= damage * player.stats.attack_power


func _on_health_depleted()->void:
	self.queue_free()
