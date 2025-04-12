extends VBoxContainer

var background_music: AudioStream = preload("res://example/assets/music/time_for_adventure.mp3")

func _ready() -> void:
	GameManager.app.audio.play_music(background_music)

func _on_button_pressed() -> void:
	#GameManager.app.router.push("one")
	GameManager.app.router.push("one", true, RouterUtility.LoadRouterJump.new())
