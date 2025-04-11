## 音频管理器
class_name AudioUtility extends FrameworkIUtility

enum BUS {
	MASTER_BUS,
	MUSIC_BUS,
	SFX_BUS,
}

var _music_audio_player_count := 2
var _sfx_audio_player_count := 5
var _max_sfx_audio_player_count := 10
var _bmusic_audio_players: Array[AudioStreamPlayer]
var _current_bmusic_audio_index := 0
var _empty_bmusic_audio_index := 1
var _sfx_audio_players: Array[AudioStreamPlayer]

func on_init():
	AudioServer.add_bus(BUS.MUSIC_BUS)
	AudioServer.set_bus_name(BUS.MUSIC_BUS, "Music")
	AudioServer.add_bus(BUS.SFX_BUS)
	AudioServer.set_bus_name(BUS.SFX_BUS, "Sfx")
	_init_music_audio()
	_init_sfx_audio()
	
func _init_music_audio():
	for i in _music_audio_player_count:
		var audio_player = AudioStreamPlayer.new()
		audio_player.process_mode = Node.PROCESS_MODE_ALWAYS
		audio_player.bus = AudioServer.get_bus_name(BUS.MUSIC_BUS)
		self.app.node.add_child(audio_player)
		_bmusic_audio_players.push_back(audio_player)

func _init_sfx_audio():
	for i in _sfx_audio_player_count:
		var audio_player = AudioStreamPlayer.new()
		audio_player.bus = AudioServer.get_bus_name(BUS.SFX_BUS)
		self.app.node.add_child(audio_player)
		_sfx_audio_players.push_back(audio_player)

## 播放音乐
func play_music(stream: AudioStream, fade_in_duration: float = 0.5, fade_out_duration: float = 0.5):
	var _audio_players = _bmusic_audio_players
	if _audio_players[_current_bmusic_audio_index].stream == stream:
		return
	if _audio_players[_current_bmusic_audio_index].playing:
		_fade_out_and_stop(_audio_players[_current_bmusic_audio_index], fade_out_duration)
		var _e = _current_bmusic_audio_index
		_current_bmusic_audio_index = _empty_bmusic_audio_index
		_empty_bmusic_audio_index = _e
	_audio_players[_current_bmusic_audio_index].stream = stream
	_play_and_fade_in(_audio_players[_current_bmusic_audio_index], fade_in_duration)

## 播放音效
func play_sfx(stream: AudioStream, pitch: float = 1.0):
	for player in _sfx_audio_players:
		if not player.playing:
			player.stream = stream
			player.pitch_scale = pitch
			player.play()
			return
	# 没有空闲
	if _sfx_audio_player_count < _max_sfx_audio_player_count:
		_sfx_audio_player_count += 1
		var audio_player = AudioStreamPlayer.new()
		audio_player.bus = AudioServer.get_bus_name(BUS.SFX_BUS)
		self.app.node.add_child(audio_player)
		_sfx_audio_players.push_back(audio_player)

## 设置总音量
## 单位百分制
func set_volume(volume: float):
	var v = volume / 100.0
	AudioServer.set_bus_volume_linear(BUS.MASTER_BUS, v)

## 设置音乐音量
## 单位百分制
func set_music_volume(volume: float):
	var v = volume / 100.0
	AudioServer.set_bus_volume_linear(BUS.MUSIC_BUS, v)

## 设置音效音量
## 单位百分制
func set_sfx_volume(volume: float):
	var v = volume / 100.0
	AudioServer.set_bus_volume_linear(BUS.SFX_BUS, v)

## 渐入
func _play_and_fade_in(audio_player: AudioStreamPlayer, fade_duration: float):
	audio_player.play()
	var tween = self.app.node.create_tween()
	tween.tween_property(audio_player, "volume_db", 0, fade_duration)
	await tween.finished

## 渐出
func _fade_out_and_stop(audio_player: AudioStreamPlayer, fade_duration: float):
	var tween = self.app.node.create_tween()
	tween.tween_property(audio_player, "volume_db", -40.0, fade_duration)
	await tween.finished
	audio_player.stop()
	audio_player.stream = null
