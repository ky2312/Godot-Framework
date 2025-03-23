## 模型接口
class_name FrameworkIModel extends RefCounted

## 依附的应用
var app: Framework

func _init() -> void:
	self.set_meta("class_name", "IModel")
## 初始化时执行
## 子类应该实现
func on_init():
	pass
