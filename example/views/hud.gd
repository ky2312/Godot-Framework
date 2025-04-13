extends CanvasLayer

func _on_reload_button_pressed() -> void:
	GameManager.app.router.go(0)
	GameManager.app.logger.info("reloaded route")
	GameManager.app.send_command(ReloadRouteCommand.new())

func _on_save_button_pressed() -> void:
	GameManager.app.game_archive.save()

func _on_load_data_button_pressed() -> void:
	GameManager.app.game_archive.load()

func _on_quit_button_pressed() -> void:
	GameManager.app.quit()
