class_name TextInputCommand extends FrameworkICommand

var _text: String

func _init(text: String) -> void:
	_text = text

func on_execute():
	var text_model := self.context.get_container(TextModelNS.ITextModel) as TextModelNS.ITextModel
	text_model.get_input1().value = _text
