## 模型接口
class_name FrameworkIModel

const constant = preload("res://addons/godot-framework/packages/constant.gd")

static var class_id = constant.I_MODEL

var context: Context

## 初始化时执行
## 子类应该实现
func on_init() -> void:
	pass

func set_context(context: Context):
	self.context = context

class Context:
	var _ioc: IoC

	var eventbus:
		get(): return _eventbus
	var _eventbus: FrameworkEvent.TriggerableEvent

	var logger: FrameworkLogger:
		get(): return _logger
	var _logger: FrameworkLogger

	func _init(ioc: IoC, eventbus: FrameworkEvent.TriggerableEvent, logger: FrameworkLogger) -> void:
		self._ioc = ioc
		self._eventbus = eventbus
		self._logger = logger
