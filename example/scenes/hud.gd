extends CanvasLayer

func _on_reload_button_pressed() -> void:
	GameManager.app.send_command(ReloadRouteCommand.new())

func _on_save_button_pressed() -> void:
	GameManager.app.send_command(SaveArchiveCommand.new("user://game/data/save.cfg", "123"))

func _on_load_data_button_pressed() -> void:
	GameManager.app.send_command(LoadArchiveCommand.new("user://game/data/save.cfg", "123"))
