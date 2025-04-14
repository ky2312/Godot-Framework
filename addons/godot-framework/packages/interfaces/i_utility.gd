## 工具接口
class_name FrameworkIUtility extends RefCounted

static var class_id = Framework.constant.I_UTILITY

var context: Context

## 通过创建传递依赖
## 允许范围 IUtility
func _init() -> void:
	pass

## 框架允许时执行
func on_init() -> void:
	pass

func set_context(context: Context):
	self.context = context

class Context:
	var _ioc: IoC

	var logger: FrameworkLogger:
		get(): return _logger
	var _logger: FrameworkLogger

	var _get_framework_node_func: Callable

	func _init(ioc: IoC, logger: FrameworkLogger, get_framework_node_func: Callable) -> void:
		self._ioc = ioc
		self._logger = logger
		self._get_framework_node_func = get_framework_node_func

	func get_framework_node() -> Node:
		return _get_framework_node_func.call()
