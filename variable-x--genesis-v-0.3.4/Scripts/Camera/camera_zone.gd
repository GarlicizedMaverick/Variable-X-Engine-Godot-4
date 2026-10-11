## NOTE: DON'T PLACE SLOPES THAT THE PLAYER CAN REACH ON LIMITS
class_name CameraZone extends Area2D


@onready var player: Player = $"../../Player"
@onready var initial_camera_zone: CameraZone = $"../Zone1"

@export var enabled: bool = true
@export var limit_left: int
@export var limit_right: int
@export var limit_top: int
@export var limit_bottom: int
@export var duration: float = 0


func _ready()->void:
	player.camera.limit_left = initial_camera_zone.limit_left
	player.camera.limit_right = initial_camera_zone.limit_right
	player.camera.limit_top = initial_camera_zone.limit_top
	player.camera.limit_bottom = initial_camera_zone.limit_bottom


#func set_zone()->void:
	#if enabled:
		#if !self.overlaps_body(player):
			#monitoring = false
		#else:
			## Check if the player is overlapping multiple zones.
			## If so, the one with the highest priority is set to monitoring.
			#
			#if self != current_zone:
				#monitoring = false
			#
			#if camera_zones.any(overlaps_body):
				#var potential_zones: Array = []
				#@warning_ignore("narrowing_conversion")
				#var greatest_priority: int = -INF
				#potential_zones = camera_zones.filter(has_overlapping_bodies)
				#
				#for zone: CameraZone in potential_zones:
					#if zone.zone_priority >= greatest_priority:
						#greatest_priority = zone.zone_priority
						#if zone.zone_priority == greatest_priority:
							#best_zone = zone
							#best_zone.monitoring = true
			#
			#current_zone = best_zone
	#else:
		#monitoring = false


func _physics_process(_delta: float)->void:
	#set_zone()
	if enabled and self.overlaps_area(player.camera_zone_collider):
		var camera: Camera2D = player.camera
		var tween: Tween =\
		get_tree().create_tween().set_parallel(true).set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
		
		tween.tween_property(camera, "limit_left", limit_left, duration)
		tween.tween_property(camera, "limit_right", limit_right, duration)
		tween.tween_property(camera, "limit_top", limit_top, duration)
		tween.tween_property(camera, "limit_bottom", limit_bottom, duration)


#func _on_body_entered(body: Player)->void:
	#if monitoring:
		#var camera: Camera2D = body.camera
		#var tween: Tween =\
		#get_tree().create_tween().set_parallel(true).set_process_mode(Tween.TWEEN_PROCESS_IDLE)
		#
		#tween.tween_property(camera, "limit_left", limit_left, duration)
		#tween.tween_property(camera, "limit_right", limit_right, duration)
		#tween.tween_property(camera, "limit_top", limit_top, duration)
		#tween.tween_property(camera, "limit_bottom", limit_bottom, duration)
		#
		##body.camera.limit_left = limit_left
		##body.camera.limit_right = limit_right
		##body.camera.limit_top = limit_top
		##body.camera.limit_bottom = limit_bottom
