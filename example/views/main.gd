extends VBoxContainer

var background_music: AudioStream = preload("res://example/assets/music/time_for_adventure.mp3")

func _ready() -> void:
	GameManager.app.audio.play_music(background_music)

func _on_mob_game_button_pressed() -> void:
	#GameManager.app.router.push("mob/one")
	GameManager.app.router.push("mob/one", true, RouterUtility.LoadRouterJump.new())

func _on_platform_jump_button_pressed() -> void:
	GameManager.app.router.push("platform_jump/level_1")

func _on_text_button_pressed() -> void:
	GameManager.app.router.push("text/main")
