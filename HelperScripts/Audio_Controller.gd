extends Node

enum Songs {
	BEETHOVEN_SONATA_NO_1,
	BEETHOVEN_SONATA_NO_6,
	CHOPIN_NOCTURNE,
	HANDEL_MESSIAH,
	TCHAIKOVSKY_NAPOLITAN_DANCE,
}

enum Sfx {
	CASH,
	CLICK,
	CLOCK_TICKING,
	CONSTRUCTION,
	FOOTSTEPS,
	GUN_FIRE,
	NEXT_TURN,
	RADIO,
	SHIP_HORN,
	THROW,
}

const SONG_BEETHOVEN_SONATA_NO_1: AudioStream = preload("res://Assets/Audio/Music/Beethoven - Sonata No_1.ogg")
const SONG_BEETHOVEN_SONATA_NO_6: AudioStream = preload("res://Assets/Audio/Music/Beethoven - Sonata No_6.ogg")
const SONG_CHOPIN_NOCTURNE: AudioStream = preload("res://Assets/Audio/Music/Chopin - Nocturne.ogg")
const SONG_HANDEL_MESSIAH: AudioStream = preload("res://Assets/Audio/Music/G. F. Handel - Messiah.ogg")
const SONG_TCHAIKOVSKY_NAPOLITAN_DANCE: AudioStream = preload("res://Assets/Audio/Music/Tchaikovsky - Napolitan Dance.ogg")

const SONG_STREAMS: Array[AudioStream] = [
	SONG_BEETHOVEN_SONATA_NO_1,
	SONG_BEETHOVEN_SONATA_NO_6,
	SONG_CHOPIN_NOCTURNE,
	SONG_HANDEL_MESSIAH,
	SONG_TCHAIKOVSKY_NAPOLITAN_DANCE,
]

const SFX_PLAYER_GROUP := &"audio_controller_sfx_players"

const SFX_CASH: AudioStream = preload("res://Assets/Audio/cash.ogg")
const SFX_CLICK: AudioStream = preload("res://Assets/Audio/click.ogg")
const SFX_CLOCK_TICKING: AudioStream = preload("res://Assets/Audio/clock_ticking.ogg")
const SFX_CONSTRUCTION: AudioStream = preload("res://Assets/Audio/construction.ogg")
const SFX_FOOTSTEPS: AudioStream = preload("res://Assets/Audio/footsteps.ogg")
const SFX_GUN_FIRE: AudioStream = preload("res://Assets/Audio/gun_fire.ogg")
const SFX_NEXT_TURN: AudioStream = preload("res://Assets/Audio/next_turn.ogg")
const SFX_RADIO: AudioStream = preload("res://Assets/Audio/radio.ogg")
const SFX_SHIP_HORN: AudioStream = preload("res://Assets/Audio/ship_horn.ogg")
const SFX_THROW: AudioStream = preload("res://Assets/Audio/throw.ogg")

var music_player: AudioStreamPlayer
var music_song_index := 0
var music_playback_enabled := false
var music_volume := 0.5
var sfx_volume := 0.5


func _ready() -> void:
	music_player = AudioStreamPlayer.new()
	music_player.name = "MusicPlayer"
	add_child(music_player)
	music_player.volume_db = linear_to_db(music_volume)
	music_player.finished.connect(_play_next_song)


func start_music() -> void:
	music_playback_enabled = true
	music_player.stop()
	music_song_index = 0
	_play_current_song()


func stop_music() -> void:
	music_playback_enabled = false
	music_player.stop()
	music_song_index = 0


func set_music_volume(volume: float) -> void:
	music_volume = clampf(volume, 0.0, 1.0)
	if is_instance_valid(music_player):
		music_player.volume_db = linear_to_db(music_volume)


func set_sfx_volume(volume: float) -> void:
	sfx_volume = clampf(volume, 0.0, 1.0)
	var volume_db := linear_to_db(sfx_volume)
	for node: Node in get_tree().get_nodes_in_group(SFX_PLAYER_GROUP):
		if node is AudioStreamPlayer:
			node.volume_db = volume_db


func _play_current_song() -> void:
	music_player.stream = SONG_STREAMS[music_song_index]
	music_player.play()


func _play_next_song() -> void:
	if not music_playback_enabled:
		return

	music_song_index = (music_song_index + 1) % SONG_STREAMS.size()
	_play_current_song()


func play_sfx(sfx: Sfx) -> void:
	_play_sfx(sfx)


func play_sfx_for_client(client_id: int, sfx: Sfx) -> void:
	if not multiplayer.is_server():
		push_error("Only the server can play a sound effect for a client.")
		return

	if client_id == multiplayer.get_unique_id():
		_play_sfx(sfx)
	else:
		_play_sfx.rpc_id(client_id, sfx)


@rpc("authority")
func _play_sfx(sfx: Sfx) -> void:
	var stream := _get_sfx_stream(sfx)
	if stream == null:
		return

	var sfx_player := AudioStreamPlayer.new()
	sfx_player.stream = stream
	sfx_player.volume_db = linear_to_db(sfx_volume)
	sfx_player.add_to_group(SFX_PLAYER_GROUP)
	add_child(sfx_player)
	sfx_player.finished.connect(sfx_player.queue_free)
	sfx_player.play()


func _get_sfx_stream(sfx: Sfx) -> AudioStream:
	match sfx:
		Sfx.CASH:
			return SFX_CASH
		Sfx.CLICK:
			return SFX_CLICK
		Sfx.CLOCK_TICKING:
			return SFX_CLOCK_TICKING
		Sfx.CONSTRUCTION:
			return SFX_CONSTRUCTION
		Sfx.FOOTSTEPS:
			return SFX_FOOTSTEPS
		Sfx.GUN_FIRE:
			return SFX_GUN_FIRE
		Sfx.NEXT_TURN:
			return SFX_NEXT_TURN
		Sfx.RADIO:
			return SFX_RADIO
		Sfx.SHIP_HORN:
			return SFX_SHIP_HORN
		Sfx.THROW:
			return SFX_THROW

	print("Unknown sound effect:" + str(sfx))
	return null
