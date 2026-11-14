extends Node

const MENU_MUSIC := "res://assets/Sounds/menu_music.mp3"
const LEVEL_MUSIC := "res://assets/Sounds/game_bg_music.mp3"
const JUMP_SFX := "res://assets/Sounds/sfx_jump.ogg"
const DIE_SFX := "res://assets/Sounds/sfx_disappear.ogg"

const MUSIC_DB := -8.0
const SFX_DB := -2.0

var _music := AudioStreamPlayer.new()
var _sfx := AudioStreamPlayer.new()
var _current := ""


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_music.volume_db = MUSIC_DB
	_music.bus = "Master"
	_sfx.volume_db = SFX_DB
	_sfx.bus = "Master"
	add_child(_music)
	add_child(_sfx)


func play_menu_music() -> void:
	_play_music(MENU_MUSIC)


func play_level_music() -> void:
	_play_music(LEVEL_MUSIC)


func play_jump() -> void:
	_play_sfx(JUMP_SFX)


func play_die() -> void:
	_play_sfx(DIE_SFX)


func stop_music() -> void:
	_current = ""
	_music.stop()


func _play_music(path: String) -> void:
	if path == _current:
		return

	var stream := load(path) as AudioStream
	if stream == null:
		return

	_loop(stream)
	_current = path
	_music.stream = stream
	_music.play()


func _play_sfx(path: String) -> void:
	var stream := load(path) as AudioStream
	if stream == null:
		return

	_sfx.stream = stream
	_sfx.play()


func _loop(stream: AudioStream) -> void:
	if stream is AudioStreamMP3:
		stream.loop = true
	elif stream is AudioStreamOggVorbis:
		stream.loop = true
	elif stream is AudioStreamWAV:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
