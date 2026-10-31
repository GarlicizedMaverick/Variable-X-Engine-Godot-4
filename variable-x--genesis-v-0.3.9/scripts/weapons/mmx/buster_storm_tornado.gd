class_name BusterStormTornado extends HitBox2D


@onready var sprite_head: AnimatedSprite2D = $SpriteHead
@onready var sprite_body: AnimatedSprite2D = $SpriteBody
@onready var sprite_tail: AnimatedSprite2D = $SpriteTail
@onready var collider: CollisionShape2D = $Collider
@onready var screen_notif: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D


const BASE_SPEED: int = 1200 # 960 if SNES-accurate

var speed: float
var direction: int
var frame_timer: int = 0
var current_animation_frame: int = 0

var global_new_body_a: AnimatedSprite2D
var global_new_body_b: AnimatedSprite2D
var global_new_body_c: AnimatedSprite2D
var global_new_body_d: AnimatedSprite2D
var global_new_body_e: AnimatedSprite2D
var global_new_body_f: AnimatedSprite2D


func _ready()->void:
	screen_notif.screen_exited.connect(_on_screen_exited)
	
	collider.shape.size.x = 64
	collider.position.x = 0
	
	sprite_head.frame = 0
	sprite_body.frame = 0
	sprite_tail.frame = 0


func _on_screen_exited()->void:
	queue_free()


func _physics_process(delta: float)->void:
	frame_timer += 1
	
	if frame_timer > 60:
		position.x += speed * direction * delta
	else:
		elongate()
	
	animate()


func elongate()->void:
	match frame_timer:
		10:
			var new_body_a: AnimatedSprite2D = sprite_body.duplicate()
			
			sprite_body.add_sibling(new_body_a)
			
			new_body_a.position = sprite_body.position
			new_body_a.flip_h = sprite_body.flip_h
			new_body_a.frame = sprite_body.frame
			new_body_a.show()
			
			push_ahead()
			global_new_body_a = new_body_a
		
		20:
			var new_body_b: AnimatedSprite2D = sprite_body.duplicate()
			
			sprite_body.add_sibling(new_body_b)
			
			new_body_b.position = sprite_body.position
			new_body_b.flip_h = sprite_body.flip_h
			new_body_b.frame = sprite_body.frame
			new_body_b.show()
			
			push_ahead()
			global_new_body_b = new_body_b
		
		30:
			var new_body_c: AnimatedSprite2D = sprite_body.duplicate()
			
			sprite_body.add_sibling(new_body_c)
			
			new_body_c.position = sprite_body.position
			new_body_c.flip_h = sprite_body.flip_h
			new_body_c.frame = sprite_body.frame
			new_body_c.show()
			
			push_ahead()
			global_new_body_c = new_body_c
		
		40:
			var new_body_d: AnimatedSprite2D = sprite_body.duplicate()
			
			sprite_body.add_sibling(new_body_d)
			
			new_body_d.position = sprite_body.position
			new_body_d.flip_h = sprite_body.flip_h
			new_body_d.frame = sprite_body.frame
			new_body_d.show()
			
			push_ahead()
			global_new_body_d = new_body_d
		
		50:
			var new_body_e: AnimatedSprite2D = sprite_body.duplicate()
			
			sprite_body.add_sibling(new_body_e)
			
			new_body_e.position = sprite_body.position
			new_body_e.flip_h = sprite_body.flip_h
			new_body_e.frame = sprite_body.frame
			new_body_e.show()
			
			push_ahead()
			global_new_body_e = new_body_e
		
		60:
			var new_body_f: AnimatedSprite2D = sprite_body.duplicate()
			
			sprite_body.add_sibling(new_body_f)
			
			new_body_f.position = sprite_body.position
			new_body_f.flip_h = sprite_body.flip_h
			new_body_f.frame = sprite_body.frame
			new_body_f.show()
			
			push_ahead()
			global_new_body_f = new_body_f


func animate()->void:
	if frame_timer % 2 == 0:
		
		# Step animation every 2 frames.
		current_animation_frame += 1
		current_animation_frame = wrapi(current_animation_frame, 0, 4)
		
		# Show on even frames.
		sprite_head.show()
		sprite_body.show()
		sprite_tail.show()
		
		if global_new_body_a != null:
			global_new_body_a.show()
		
		if global_new_body_b != null:
			global_new_body_b.show()
		
		if global_new_body_c != null:
			global_new_body_c.show()
		
		if global_new_body_d != null:
			global_new_body_d.show()
		
		if global_new_body_e != null:
			global_new_body_e.show()
		
		if global_new_body_f != null:
			global_new_body_f.show()
	
	# Hide on odd frames.
	else:
		sprite_head.hide()
		sprite_body.hide()
		sprite_tail.hide()
	
		if global_new_body_a != null:
			global_new_body_a.hide()
		
		if global_new_body_b != null:
			global_new_body_b.hide()
		
		if global_new_body_c != null:
			global_new_body_c.hide()
		
		if global_new_body_d != null:
			global_new_body_d.hide()
		
		if global_new_body_e != null:
			global_new_body_e.hide()
		
		if global_new_body_f != null:
			global_new_body_f.hide()
	
	sprite_head.frame = current_animation_frame
	sprite_body.frame = current_animation_frame
	sprite_tail.frame = current_animation_frame
	
	if global_new_body_a != null:
		global_new_body_a.frame = current_animation_frame
	
	if global_new_body_b != null:
		global_new_body_b.frame = current_animation_frame
	
	if global_new_body_c != null:
		global_new_body_c.frame = current_animation_frame
	
	if global_new_body_d != null:
		global_new_body_d.frame = current_animation_frame
	
	if global_new_body_e != null:
		global_new_body_e.frame = current_animation_frame
	
	if global_new_body_f != null:
		global_new_body_f.frame = current_animation_frame


func push_ahead()->void:
	sprite_body.position.x += 32 * direction
	sprite_head.position.x += 32 * direction
	
	collider.position.x += 16 * direction
	collider.shape.size.x += 32
