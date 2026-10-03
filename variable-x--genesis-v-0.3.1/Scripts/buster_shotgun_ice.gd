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
		# Split into 5 shards, then delete self.
		## There's probably a WAY more efficient way to do this...
		## I'll look into it later. I'm just glad it's done.
		
		const OFFSET: float = -32
		
		var new_shrapnel_a: HitBox2D = shotgun_ice_shrapnel.instantiate()
		var new_shrapnel_b: HitBox2D = shotgun_ice_shrapnel.instantiate()
		var new_shrapnel_c: HitBox2D = shotgun_ice_shrapnel.instantiate()
		var new_shrapnel_d: HitBox2D = shotgun_ice_shrapnel.instantiate()
		var new_shrapnel_e: HitBox2D = shotgun_ice_shrapnel.instantiate()
		
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
