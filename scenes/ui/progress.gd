extends Node

const LEVEL_SELECT := "res://scenes/ui/level_select.tscn"

const LEVELS := [
	"res://scenes/level/level_1.tscn",
	"res://scenes/level/level_2.tscn",
	"res://scenes/level/level_3.tscn",
]

var unlocked_count := 1


func level_count() -> int:
	return LEVELS.size()


func scene_path(index: int) -> String:
	return LEVELS[index]


func is_unlocked(index: int) -> bool:
	return index < unlocked_count


func complete(index: int) -> void:
	unlocked_count = maxi(unlocked_count, index + 2)


func finish_level(index: int) -> void:
	complete(index)
	get_tree().change_scene_to_file(LEVEL_SELECT)
