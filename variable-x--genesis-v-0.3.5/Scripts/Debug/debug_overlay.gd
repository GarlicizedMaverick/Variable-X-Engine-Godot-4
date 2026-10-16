class_name DebugOverlay extends Label


@export var show_debug: bool = true
@onready var player: Player

var FPS: float = 0
var draw_calls: int = 0
var frame_time: float = 0
var VRAM: float = 0


func _ready()->void:
	# This is some grade-A hacky stuff, here. I'm sure someone'll change it later.
	await get_tree().physics_frame
	player = $"/root/VariableX/MegaManX/SubViewportContainer/SubViewport/World/EntityRoot/Player"


func _process(delta: float)->void:
	if player == null:
		return
	if !show_debug or player == null:
		text = ""
		return
	FPS = Engine.get_frames_per_second()
	draw_calls =\
	RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME)
	frame_time = delta
	VRAM = RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_VIDEO_MEM_USED)
	var data: String = \
	"FPS: " + str(FPS) + "\n" + \
	"Frame Time: " + str(snappedf(frame_time, 0.000001)) + " s" + "\n" + \
	"Draw Calls: " + str(draw_calls) + "\n" + \
	"VRAM: " + str(snappedf((VRAM / 1024.0 / 1024.0), 0.000001)) + " MB" + "\n" + \
	"State: " + str(player.MainState.find_key(player.current_state)) + "\n" + \
	"Position: " + str(player.global_position) + "\n" + \
	"Velocity: " + str(player.velocity) + "\n" + \
	"Slope Grade: " + str(player.get_accurate_floor_angle()) + "\n" + \
	"Ki: " + str(player.stats.ki) + "\n" + \
	"Attack: " + str(player.stats.attack_power) + "\n" + \
	"Defense: " + str(player.stats.defense) + "\n" + \
	"HP: " + str(player.stats.health) + "\n" + \
	"Charge Time: " + str(snappedf(player.player_weapons.charge_timer, 0.001))
	
	text = data
