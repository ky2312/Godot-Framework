## 工具接口
class_name FrameworkIUtility extends RefCounted

## 依附的应用
var app: Framework

func _init() -> void:
	self.set_meta("class_name", "IUtility")
## 初始化时执行
## 子类应该实现
func on_init():
	pass
