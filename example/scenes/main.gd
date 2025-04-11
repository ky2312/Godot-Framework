extends VBoxContainer


func _on_button_pressed() -> void:
	GameManager.app.router.push("one")
