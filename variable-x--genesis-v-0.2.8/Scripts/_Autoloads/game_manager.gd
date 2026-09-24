extends Node


enum GameMode
{
	MAIN_MENU = 0,
	MMX = 1,
	EP = 2,
	II = 3
}
var current_game_mode: GameMode
var mega_man_x_finished_at_least_once: bool


func _ready()->void:
	current_game_mode = GameMode.MMX
