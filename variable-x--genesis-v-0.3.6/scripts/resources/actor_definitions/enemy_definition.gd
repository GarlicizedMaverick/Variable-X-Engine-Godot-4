# Stolen from FAT Earth Studios (http://www.youtube.com/watch?v=gVYeNZhROxM)
class_name EnemyDefinition extends Resource
## Provides the PackedScene resource, Preview Texture, and Spawn Configuration for enemies.


@export var scene: PackedScene ## Scene containing enemy to be spawned.
@export var preview_texture: Texture2D ## Image displayed in the editor to represent the enemy.

@export_category("Spawn Behavior")
## Defines how the spawner determines when this enemy should respawn.
## NOTE: These values are used by the spawner unless override_enemy_default is enabled.
@export var respawn_mode: Spawner.RespawnMode

## Base cooldown applied when using ON_TIMER respawn mode.
## This value is used after the enemy is removed from the scene.
@export_range(0, 60, 0.05) var cooldown_time: float = 0

## Adds a random value between 0 and this amount to the cooldown_time.
@export_range(0, 60, 0.05) var randomize_cooldown_time: float = 0
