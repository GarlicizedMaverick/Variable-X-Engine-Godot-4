# The original X1 uses two tables for regular enemies and a custom table for each boss.
# This allows for a custom table for each enemy: boss or otherwise.
class_name MMXEnemyDamageTable extends Resource


## A custom table for determining how much damage all of the player's attacks deal to an enemy.
@export var damage_table: Dictionary[String, float] =\
{
	"Lemon": 1, # Default X-buster shot
	"Dash Lemon": 2, # Default shot while dashing
	"Lime": 3, # X-buster charge level 1
	"Blueberry": 4, # X-buster charge level 2
	"Raspberry": 2, # Spiral Crush Buster (each part)
	"Pseudoken": 32,
	"Hadouken Weak": 32,
	"Hadouken": 64,
	"Shotgun Ice": 3,
	"Shotgun Ice Shrapnel": 1,
	"Electric Spark Ball H1": 3,
	"Electric Spark Ball H2": 4,
	"Electric Spark Ball V": 3,
	"Electric Spark Charged": 240, # * delta, since it's a continuous hitbox (4 damage per frame)
	"Electric Spark Underwater": 0.5,
	"Rolling Shield": 4,
	"Rolling Shield Charged": 4,
	"Homing Torpedo": 3,
	"Homing Torpedo Charged": 6,
	"Boomerang Cutter": 2,
	"Boomerang Cutter Charged": 240, # * delta
	"Chameleon Sting": 240, # * delta
	"Storm Tornado": 60, # * delta
	"Storm Tornado Charged": 120, # * delta
	"Fire Wave": 60 # * delta
}
