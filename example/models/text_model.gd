class_name TextModelNS

class ITextModel extends FrameworkIModel:
    func get_input1() -> FrameworkBindableProperty:
        return

class TextModel extends ITextModel:
    var input1 := FrameworkBindableProperty.new("")

    func get_input1():
        return input1
