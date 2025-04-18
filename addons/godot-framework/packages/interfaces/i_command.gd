## 命令接口
class_name FrameworkICommand

static var class_id = Framework.constant.I_COMMAND

var context: Context

## 通过创建传递参数
func _init() -> void:
	pass

## 命令被调用时执行
## 子类应该实现
func on_execute() -> void:
	pass

func set_context(context: Context):
	self.context = context

class Context:
	var _ioc: IoC

	var logger: FrameworkLogger:
		get(): return _logger
	var _logger: FrameworkLogger

	func _init(ioc: IoC, logger: FrameworkLogger):
		self._ioc = ioc
		self._logger = logger

	func get_container(inter: Object) -> Object:
		var valid_tag = [Framework.constant.I_SYSTEM, Framework.constant.I_MODEL]
		var result = false
		for t in valid_tag:
			if _ioc.is_valid_class(t, inter):
				result = true
				break
		if not result:
			_logger.error("This interface is not a valid interface.")
			return
		return self._ioc.get_container(inter)
