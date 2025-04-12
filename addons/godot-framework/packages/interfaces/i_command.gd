## 命令接口
class_name FrameworkICommand extends RefCounted

static var class_id = Framework.constant.I_COMMAND

## 依附的应用
var app: Framework

## 命令被调用时执行
## 子类应该实现
func on_call(data) -> void:
	pass
