# Stolen from FAT Earth Studios
class_name VariableX extends Node
## Main entry point for the game.
## Responsible for setting up the World layers and coordinating high-level systems.


## This is probably moving to the MegaManX node later.
const STAGE_CHILL_PENGUIN_TEST: String = "uid://408m5cojxf5n"
const PLAYER_SCENE_UID: String = "uid://b1cc0hrphc6sa"

## Systems nodes
### Figure out the whole "three games in one" thing later...
@onready var systems_root: Node = $MegaManX/Systems

# Game World root nodes
## Figure out the whole "three games in one" thing later...
@onready var stage_root: Node2D = $MegaManX/SubViewportContainer/SubViewport/World/StageRoot
@onready var entity_root: Node2D = $MegaManX/SubViewportContainer/SubViewport/World/EntityRoot
@onready var vfx_root: Node2D = $MegaManX/SubViewportContainer/SubViewport/World/VFXRoot

# UI root nodes
## Figure out the whole "three games in one" thing later...
@onready var hud_root: Control = $MegaManX/HUDLayer/HUDRoot
@onready var transition_root: Control = $MegaManX/TransitionLayer/TransitionRoot
@onready var debug_root: Control = $MegaManX/DebugLayer/DebugRoot


var player: Player = null
var _current_stage: BaseStage = null


func _ready()->void:
	_init_systems()
	_init_player()
	_load_stage(STAGE_CHILL_PENGUIN_TEST)


func _input(event: InputEvent)->void:
	if not OS.is_debug_build():
		return
	
	if event.is_action_pressed(&"debug_quit"):
		quit_game()


## Called to quit the application.
## Propagates the close request notification to every node, and then quits the application.
func quit_game()->void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()


## Loads a stage scene that must extend BaseStage.
func _load_stage(stage_scene: String)->void:
	# Make sure this is called during idle time.
	_perform_stage_load.call_deferred(stage_scene)


func _perform_stage_load(stage_scene_uid: String)->void:
	if is_instance_valid(_current_stage):
		_current_stage.queue_free()
		_current_stage = null
		# Wait to allow the queued deletion to process so it is out of the SceneTree.
		await get_tree().process_frame
	
	var new_stage_packed: PackedScene =\
	ResourceLoader.load(stage_scene_uid, "PackedScene") as PackedScene
	
	if new_stage_packed == null:
		push_error("Could not load stage as a PackedScene: " + stage_scene_uid)
		return
	
	var new_stage: Node = new_stage_packed.instantiate()
	
	if not new_stage:
		push_error("Could not instantiate new stage: " + stage_scene_uid)
		return
	
	if new_stage is not BaseStage:
		new_stage.free() # Stage must be freed to avoid unreferenced orphan nodes.
		push_error("Loaded stage is not of type BaseStage: " + stage_scene_uid)
		return
	
	_current_stage = new_stage as BaseStage
	
	stage_root.add_child(_current_stage)
	
	_place_player_at_level_spawn()


## Instantiates the player and adds it to the entity layer.
func _init_player()->void:
	var player_scene: PackedScene = ResourceLoader.load(PLAYER_SCENE_UID) as PackedScene
	if player_scene == null:
		push_error("Could not load player scene: " + PLAYER_SCENE_UID)
		return
	
	var player_instance: Node = player_scene.instantiate()
	if not player_instance:
		push_error("Could not instantiate player scene: " + PLAYER_SCENE_UID)
		return
	
	if player_instance is not Player:
		player_instance.free() # Node must be freed to avoid unreferenced orphan nodes.
		push_error("Loaded player scene is not of type Player: " + PLAYER_SCENE_UID)
		return
	
	player = player_instance as Player
	
	entity_root.add_child(player)


## Finds the default spawn location in currently loaded stage...
## ...and places the Player at that position.
func _place_player_at_level_spawn()->void:
	if player == null:
		push_error("Cannot place player into stage because it is null.")
		return
	if _current_stage == null:
		push_error("Cannot place player into stage because stage is null.")
		return
	
	player.global_position = _current_stage.get_default_player_spawn()


## Set up high-level systems.
func _init_systems()->void:
	_init_spawn_manager()


func _init_spawn_manager()->void:
	#var spawn_manager_scene: PackedScene = ResourceLoader.load(SPAWN_MANAGER_UID) as PackedScene
	#if spawn_manager_scene == null:
		#push_error("Could not load Spawn Manager: " + SPAWN_MANAGER_UID)
		#return
	#
	#var spawn_manager_instance: Node = spawn_manager_scene.instantiate()
	#if not spawn_manager_instance:
		#push_error("Could not instantiate Spawn Manager scene: " + SPAWN_MANAGER_UID)
		#return
	#
	#if spawn_manager_instance is not SpawnManager:
		#spawn_manager_instance.free() # Node must be freed to avoid unreferenced orphan nodes.
		#push_error("Loaded SpawnManager scene is not of type SpawnManager: " + SPAWN_MANAGER_UID)
		#return
	#
	#spawn_manager = spawn_manager_instance as SpawnManager
	#
	#systems_root.add_child(spawn_manager)
	pass
