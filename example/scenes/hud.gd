extends CanvasLayer

func _on_reload_button_pressed() -> void:
	GameManager.app.reload_scene()

func _on_save_button_pressed() -> void:
	GameManager.app.send_command(GameSaveCommand.new())

func _on_load_data_button_pressed() -> void:
	GameManager.app.send_command(GameLoadCommand.new())
