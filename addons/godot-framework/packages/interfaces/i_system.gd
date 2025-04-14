## 系统接口
class_name FrameworkISystem

static var class_id = Framework.constant.I_SYSTEM

var context: Context

## 通过创建传递依赖
## 允许范围 IModel IUtility
func _init() -> void:
	pass

## 框架允许时执行
func on_init() -> void:
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
