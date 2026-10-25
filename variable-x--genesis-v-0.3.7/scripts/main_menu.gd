class_name MainMenu extends Control


var test_stage_scene: String = "res://Scenes/UI/gameplay_container.tscn"


func _ready()->void:
	%MegaManX.pressed.connect(select_mega_man_x)


func select_mega_man_x()->void:
	get_tree().change_scene_to_file(test_stage_scene)
