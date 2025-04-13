## 系统接口
class_name FrameworkISystem

static var class_id = Framework.constant.I_SYSTEM

var context: Context

## 初始化时执行
## 子类应该实现
func on_init():
	pass

func set_context(context: Context):
	self.context = context

class Context:
	var _ioc: IoC

	var eventbus:
		get(): return _eventbus
	var _eventbus: FrameworkEvent

	var logger: FrameworkLogger:
		get(): return _logger
	var _logger: FrameworkLogger

	func _init(ioc: IoC, eventbus: FrameworkEvent, logger: FrameworkLogger) -> void:
		self._ioc = ioc
		self._eventbus = eventbus
		self._logger = logger

	func get_model(cls: Object) -> FrameworkIModel:
		return _ioc.get_model(cls)

	func get_utility(cls: Object) -> FrameworkIUtility:
		return _ioc.get_utility(cls)
