## 命令接口
extends RefCounted

## 依附的应用
var app: Framework

func _init() -> void:
	self.set_meta("class_name", "ICommand")
## 命令被调用时执行
## 子类应该实现
func on_execute():
	pass
