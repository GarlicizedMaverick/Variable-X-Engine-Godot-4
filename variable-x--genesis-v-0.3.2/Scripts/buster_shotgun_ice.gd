class_name BusterShotgunIce extends HitBox2D


@onready var sprite: Sprite2D = $Sprite
@onready var screen_notif: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
@onready var shrapnel_spawn: Marker2D = $ShrapnelSpawn
@onready var wall_detector: Area2D = $WallDetector

@export var shotgun_ice_shrapnel: PackedScene

const SPEED: int = 1200

var direction: int


func _ready()->void:
	screen_notif.screen_exited.connect(_on_screen_exited)


func _physics_process(delta: float)->void:
	position += transform.x * SPEED * direction * delta
	collide()


func _on_screen_exited()->void:
	queue_free()


func collide()->void:
	if wall_detector.has_overlapping_bodies() or self.has_overlapping_areas():
		# Hide sprite, but don't despawn yet.
		sprite.hide()
		
		# Wait a frame, split into 5 shards, then delete self.
		## There's probably a WAY more efficient way to set the shrapnel's properties...
		## I'll look into it later. I'm just glad it's done.
		await get_tree().physics_frame
		const OFFSET: float = -16
		
		var new_shrapnel_a: HitBox2D = shotgun_ice_shrapnel.instantiate()
		var new_shrapnel_b: HitBox2D = shotgun_ice_shrapnel.instantiate()
		var new_shrapnel_c: HitBox2D = shotgun_ice_shrapnel.instantiate()
		var new_shrapnel_d: HitBox2D = shotgun_ice_shrapnel.instantiate()
		var new_shrapnel_e: HitBox2D = shotgun_ice_shrapnel.instantiate()
		
		# Gives the shrapnel slightly different amounts of time before they're active.
		# This is so they don't *all* immediately disappear whenever a Shotgun Ice bullet...
		# ...spawns directly inside a hurtbox.
		# This also makes it so shrapnel don't get unnecessarily consumed...
		# ...whenever they simultaneously hit an enemy that is already about to die.
		# The amount of time itself really doesn't matter, hence the lack of delta.
		new_shrapnel_a.collision_enabler_frame_timer = 0
		new_shrapnel_b.collision_enabler_frame_timer = 1
		new_shrapnel_c.collision_enabler_frame_timer = 2
		new_shrapnel_d.collision_enabler_frame_timer = 1
		new_shrapnel_e.collision_enabler_frame_timer = 0
		
		new_shrapnel_a.direction = -direction
		new_shrapnel_b.direction = -direction
		new_shrapnel_c.direction = -direction
		new_shrapnel_d.direction = -direction
		new_shrapnel_e.direction = -direction
		
		self.add_sibling(new_shrapnel_a)
		self.add_sibling(new_shrapnel_b)
		self.add_sibling(new_shrapnel_c)
		self.add_sibling(new_shrapnel_d)
		self.add_sibling(new_shrapnel_e)
		
		new_shrapnel_a.top_level = true
		new_shrapnel_b.top_level = true
		new_shrapnel_c.top_level = true
		new_shrapnel_d.top_level = true
		new_shrapnel_e.top_level = true
		
		new_shrapnel_a.position.x = shrapnel_spawn.global_position.x + (OFFSET * direction)
		new_shrapnel_c.position.x = shrapnel_spawn.global_position.x + (OFFSET * direction)
		new_shrapnel_b.position.x = shrapnel_spawn.global_position.x + (OFFSET * direction)
		new_shrapnel_d.position.x = shrapnel_spawn.global_position.x + (OFFSET * direction)
		new_shrapnel_e.position.x = shrapnel_spawn.global_position.x + (OFFSET * direction)
		
		new_shrapnel_a.position.y = shrapnel_spawn.global_position.y
		new_shrapnel_b.position.y = shrapnel_spawn.global_position.y
		new_shrapnel_c.position.y = shrapnel_spawn.global_position.y
		new_shrapnel_d.position.y = shrapnel_spawn.global_position.y
		new_shrapnel_e.position.y = shrapnel_spawn.global_position.y
		
		new_shrapnel_a.angle = new_shrapnel_a.angle_a
		new_shrapnel_b.angle = new_shrapnel_b.angle_b
		new_shrapnel_c.angle = new_shrapnel_c.angle_c
		new_shrapnel_d.angle = new_shrapnel_d.angle_d
		new_shrapnel_e.angle = new_shrapnel_e.angle_e
		
		queue_free()
