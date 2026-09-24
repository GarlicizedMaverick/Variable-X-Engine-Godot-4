class_name DebugOverlay extends Label


@export var show_debug: bool = true
@export var player: Player

var FPS: float = 0
var draw_calls: int = 0
var frame_time: float = 0
var VRAM: float = 0


func _process(delta: float)->void:
	if !show_debug:
		text = ""
		return
	FPS = Engine.get_frames_per_second()
	draw_calls =\
	RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME)
	frame_time = delta
	VRAM = RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_VIDEO_MEM_USED)
	var data: String = \
	"FPS: " + str(FPS) + "\n" + \
	"Frame Time: " + str(frame_time) + " s" + "\n" + \
	"Draw Calls: " + str(draw_calls) + "\n" + \
	"VRAM: " + str(VRAM / 1024.0 / 1024.0) + " MB" + "\n" + \
	"State: " + str(player.MainState.find_key(player.current_state)) + "\n" + \
	"Position: " + str(player.global_position) + "\n" + \
	"Velocity: " + str(player.velocity) + "\n" + \
	"Slope Grade: " + str(player.get_accurate_floor_angle()) + "\n" + \
	"Ki: " + str(player.stats.ki) + "\n" + \
	"HP: " + str(player.stats.health)
	text = data
