class_name IoC

var _ready_build_funcs: Array[Callable]

var _containers: Dictionary

var _eventbus: FrameworkEvent

var _logger: FrameworkLogger

var _get_node_func: Callable

static func is_valid_class(cls_id: String, cls: Object) -> bool:
	if not "new" in cls:
		return false
	if not cls.class_id == cls_id:
		return false
	return true

func _init(eventbus: FrameworkEvent, logger: FrameworkLogger, get_node_func: Callable) -> void:
	self._eventbus = eventbus
	self._logger = logger
	self._get_node_func = get_node_func

func build():
	for cls in _containers:
		var c = _containers.get(cls)
		match cls.class_id:
			Framework.constant.I_MODEL:
				c.on_init()
			Framework.constant.I_SYSTEM:
				c.on_init()
			Framework.constant.I_UTILITY:
				c.on_init()

## 注册系统层实例
func register_system(cls: Object) -> FrameworkISystem:
	if _containers.has(cls):
		push_error("Cannot register a system class with the same name.")
		return
	if not is_valid_class(Framework.constant.I_SYSTEM, cls):
		push_error("This class is not a system class.")
		return
	var ins = cls.new()
	var context := FrameworkISystem.Context.new(self, _eventbus, _logger)
	ins.set_context(context)
	_containers.set(cls, ins)
	return ins

## 获取系统层实例
func get_system(cls: Object) -> FrameworkISystem:
	if not _containers.has(cls):
		push_error("Cannot get a system class with the name.")
		return
	return _containers.get(cls)

## 注册模型层实例
func register_model(cls: Object) -> FrameworkIModel:
	if _containers.has(cls):
		push_error("Cannot register a model class with the same name.")
		return
	if not is_valid_class(Framework.constant.I_MODEL, cls):
		push_error("This class is not a model class.")
		return
	var event: FrameworkEvent.OnlyTriggerEvent = _eventbus.get_only_trigger_event()
	var contexnt := FrameworkIModel.Context.new(self, event, _logger)
	var ins = cls.new()
	ins.set_context(contexnt)
	_containers.set(cls, ins)
	return ins

## 获取模型层实例
func get_model(cls: Object) -> FrameworkIModel:
	if not _containers.has(cls):
		push_error("Cannot get a model class with the name.")
		return
	return _containers.get(cls)

## 注册工具层实例
func register_utility(cls: Object) -> FrameworkIUtility:
	if _containers.has(cls):
		push_error("Cannot register a utility class with the same name.")
		return
	if not is_valid_class(Framework.constant.I_UTILITY, cls):
		push_error("This class is not a utility class.")
		return
	var ins = cls.new()
	var get_framework_node = func() -> Node:
		var node = _get_node_func.call() as Node
		return node
	var context := FrameworkIUtility.Context.new(self, _logger, get_framework_node)
	ins.set_context(context)
	_containers.set(cls, ins)
	return ins

## 获取工具层实例
func get_utility(cls: Object) -> FrameworkIUtility:
	if not _containers.has(cls):
		push_error("Cannot get a utility class with the name.")
		return
	return _containers.get(cls)
