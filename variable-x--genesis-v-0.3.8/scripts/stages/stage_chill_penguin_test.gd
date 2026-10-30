# Stolen from FAT Earth Studios
class_name StageChillPenguinTest extends BaseStage

#@onready var entity_root: Node2D = $MegaManX/SubViewportContainer/SubViewport/World/EntityRoot
@onready var default_player_spawn: Marker2D = $PlayerSpawn1
@onready var enemy_container: Node = $EnemyContainer
@onready var zone_1: CameraZone = $CameraZones/Zone1


func get_default_player_spawn()->Vector2:
	return default_player_spawn.global_position


func _ready()->void:
	pass
