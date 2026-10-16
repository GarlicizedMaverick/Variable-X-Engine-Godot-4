# Stolen from FAT Earth Studios (http://www.youtube.com/watch?v=gVYeNZhROxM)
class_name SpawnManager extends Node
## High-level manager for spawning entities into the game world.


var _entity_layer: Node2D = null

## Spawns the input enemy scene into the entity layer with the input global transform.
## Returns reference to enemy that was just spawned or null if spawn failed.
func spawn_enemy(enemy_scene: PackedScene, global_transform: Transform2D)->BaseEnemy:
	if _entity_layer == null:
		return null
	
	# Must be of BaseEnemy type to spawn.
	var enemy: BaseEnemy = enemy_scene.instantiate() as BaseEnemy
	if enemy == null:
		return null
	
	# Add to the entity layer and place it in the world.
	_entity_layer.add_child(enemy)
	enemy.global_transform = global_transform
	
	return enemy
