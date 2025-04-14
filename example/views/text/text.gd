extends Node2D

@onready var text_area: TextEdit = %TextArea
@onready var echo_text: Label = %EchoText

func _ready() -> void:
	var text_model := GameManager.app.get_container(TextModelNS.TextModel) as TextModelNS.TextModel
	text_model.input1.register(func(input1):
		echo_text.text = input1
	).unregister_when_node_exit_tree(self)

func _on_text_area_text_changed() -> void:
	GameManager.app.send_command(TextInputCommand.new(text_area.text))
