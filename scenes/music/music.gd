extends Node2D

const vol = -6.0
const fade_time = 10

onready var songs = {
	"fight": $FightSong,
	"boss": $BossSong,
	"tut": $TutSong,
	"win": $WinSong
}

func _ready():
	Signals.connect("play_music", self, "play")
	Signals.connect("fade_music", self, "fade")
	Signals.connect("stop_music", self, "stop")

func fade():
	for song in songs.values():
		$Tween.interpolate_property(song, "volume_db", song.volume_db, -80, fade_time)
	$Tween.start()

func stop(click):
	for song in songs.values():
		song.stop()
	if click:
		$Click.play()
	else:
		$TapeStop.play()

func play(song_name):
	var playing = false
	for key in songs:
		if key != song_name:
			playing = playing or songs[key].playing
			songs[key].stop()
	$Tween.stop_all()
	var song = songs[song_name]
	if song.volume_db < vol:
		song.stop()
	song.volume_db = vol
	if not song.playing:
		if playing:
			$Load.play()
			yield(get_tree().create_timer(1), "timeout")
		$Start.play()
		yield(get_tree().create_timer(0.5), "timeout")
		song.play()
