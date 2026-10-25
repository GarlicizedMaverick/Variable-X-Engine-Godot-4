# Stolen from Ludonauta (https://www.youtube.com/watch?v=t24gdhWM3Wo)
@tool
class_name Spawner extends Marker2D


signal entity_spawned(entity: Node2D)

@onready var sprite: Sprite2D = $Sprite2D
@onready var screen_notif: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
@onready var respawn_timer: Timer = $RespawnTimer
@onready var player: Player = $"../../../../../EntityRoot/Player"

@export var enemy_definition: EnemyDefinition

@export_category("DEBUG")
@export var do_not_spawn: bool = false

@export_category("Spawner Options")
@export var can_respawn: bool = true

enum RespawnMode
{
	ON_VISIBLE = 0,
	ON_TIMER
}

@export_flags("LEFT", "RIGHT", "TOP", "BOTTOM")
## Only spawns the entity from any given direction. Defaults to all directions.
var spawn_from: int = 15

var ready_to_respawn: bool = true
var entity_currently_on_screen: bool = false


func _ready()->void:
	screen_notif.screen_entered.connect(_on_screen_entered)
	screen_notif.screen_exited.connect(_on_screen_exited)
	respawn_timer.timeout.connect(_on_respawn_timer_timeout)
	entity_spawned.connect(_get_entity_just_spawned)


func _draw()->void:
	if Engine.is_editor_hint():
		sprite.texture = enemy_definition.preview_texture


func _get_entity_just_spawned(entity: Node2D)->void:
	entity.screen_notif.screen_exited.connect(_on_entity_screen_exited)


func _on_screen_entered()->void:
	if do_not_spawn == true:
		return
	
	entity_currently_on_screen = true
	
	if ready_to_respawn == true:
		if enemy_definition.respawn_mode == RespawnMode.ON_VISIBLE:
			handle_visible_spawn()


func _on_screen_exited()->void:
	if can_respawn == true:
		if enemy_definition.respawn_mode == RespawnMode.ON_VISIBLE:
			can_respawn = true


func _on_entity_screen_exited()->void:
	entity_currently_on_screen = false
	ready_to_respawn = true


func _on_respawn_timer_timeout()->void:
	if can_respawn == true:
		if enemy_definition.respawn_mode == RespawnMode.ON_TIMER:
			can_respawn = false
			spawn()


func _physics_process(_delta: float)->void:
	#print(entity_currently_on_screen)
	
	if enemy_definition.respawn_mode == RespawnMode.ON_VISIBLE:
		if entity_currently_on_screen:
			ready_to_respawn = false
			can_respawn = false
		else:
			ready_to_respawn = true
	else:
		# ON_TIMER
		pass


func spawn()->Node2D:
	var entity: Node2D = enemy_definition.scene.duplicate(true).instantiate()
	self.add_child(entity)
	entity.top_level = true
	entity.global_position = global_position
	emit_signal("entity_spawned", entity)
	return entity


func handle_visible_spawn()->void:
	match spawn_from:
		0:
			can_respawn = false
		
		1:
			# LEFT
			if can_spawn_from_left():
				can_respawn = true
				spawn()
		
		2:
			# RIGHT
			if can_spawn_from_right():
				can_respawn = true
				spawn()
		
		3:
			# LEFT and RIGHT
			if can_spawn_from_left() or can_spawn_from_right():
				can_respawn = true
				spawn()
		
		4:
			# TOP
			if can_spawn_from_top():
				can_respawn = true
				spawn()
		
		5:
			# LEFT and TOP
			if can_spawn_from_left() or can_spawn_from_top():
				can_respawn = true
				spawn()
		
		6:
			# RIGHT and TOP
			if can_spawn_from_right() or can_spawn_from_top():
				can_respawn = true
				spawn()
		
		7:
			# LEFT and RIGHT and TOP
			if can_spawn_from_left() or can_spawn_from_right() or can_spawn_from_top():
				can_respawn = true
				spawn()
		
		8:
			# BOTTOM
			if can_spawn_from_bottom():
				can_respawn = true
				spawn()
		
		9:
			# LEFT and BOTTOM
			if can_spawn_from_left() or can_spawn_from_bottom():
				can_respawn = true
				spawn()
		
		10:
			 # RIGHT and BOTTOM
			if can_spawn_from_right() or can_spawn_from_bottom():
				can_respawn = true
				spawn()
		
		11:
			# LEFT and RIGHT and BOTTOM
			if can_spawn_from_left() or can_spawn_from_right() or can_spawn_from_bottom():
				can_respawn = true
				spawn()
		
		12:
			# TOP and BOTTOM
			if can_spawn_from_top() or can_spawn_from_bottom():
				can_respawn = true
				spawn()
		
		13:
			# LEFT and TOP and BOTTOM
			if can_spawn_from_left() or can_spawn_from_top() or can_spawn_from_bottom():
				can_respawn = true
				spawn()
		
		14:
			# RIGHT and TOP and BOTTOM
			if can_spawn_from_right() or can_spawn_from_top() or can_spawn_from_bottom():
				can_respawn = true
				spawn()
		
		15:
			# LEFT and RIGHT and TOP and BOTTOM
			if can_spawn_from_left() or can_spawn_from_right() or\
			can_spawn_from_top() or can_spawn_from_bottom():
				can_respawn = true
				spawn()


func can_spawn_from_left()->bool:
	if player.global_position.x <= global_position.x:
		return true
	else:
		return false


func can_spawn_from_right()->bool:
	if player.global_position.x > global_position.x:
		return true
	else:
		return false


func can_spawn_from_top()->bool:
	if player.global_position.y <= global_position.y:
		return true
	else:
		return false


func can_spawn_from_bottom()->bool:
	if player.global_position.y > global_position.y:
		return true
	else:
		return false
