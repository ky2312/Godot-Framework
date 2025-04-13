## 工具接口
class_name FrameworkIUtility

const constant = preload("res://addons/godot-framework/packages/constant.gd")

static var class_id = constant.I_UTILITY

var context: Context

## 初始化时执行
## 子类应该实现
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
	
	func get_utility(cls: Object) -> FrameworkIUtility:
		return _ioc.get_utility(cls)
