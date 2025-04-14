class_name IoC

## 依赖
## Dictionary[interface: Object, instance: Object]
var _containers: Dictionary[Object, Object]

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
	for inter in _containers:
		if _containers[inter].has_method("on_init"):
			_containers[inter].on_init()

func register_container(inter: Object, ins: Object) -> Object:
	if _containers.has(inter):
		push_error("Cannot register a interface with the same name.")
		return
	match inter.class_id:
		Framework.constant.I_MODEL:
			return _register_model(inter, ins)
		Framework.constant.I_SYSTEM:
			return _register_system(inter, ins)
		Framework.constant.I_UTILITY:
			return _register_utility(inter, ins)
		_:
			return

func get_container(inter: Object) -> Object:
	if not _containers.has(inter):
		push_error("Cannot get a interface with the name.")
		return
	return _containers.get(inter)

func unregister_container(inter: Object):
	_containers.erase(inter)

func _register_system(inter: Object, ins: Object) -> FrameworkISystem:
	if not is_valid_class(Framework.constant.I_SYSTEM, inter):
		push_error("This interface is not a system interface.")
		return
	var context := FrameworkISystem.Context.new(self, _eventbus, _logger)
	ins = _get_instance(ins)
	ins.set_context(context)
	_containers.set(inter, ins)
	return ins

func _register_model(inter: Object, ins: Object) -> FrameworkIModel:
	if not is_valid_class(Framework.constant.I_MODEL, inter):
		push_error("This interface is not a model interface.")
		return
	var event: FrameworkEvent.OnlyTriggerEvent = _eventbus.get_only_trigger_event()
	var contexnt := FrameworkIModel.Context.new(self, event, _logger)
	ins = _get_instance(ins)
	ins.set_context(contexnt)
	_containers.set(inter, ins)
	return ins

func _register_utility(inter: Object, ins: Object) -> FrameworkIUtility:
	if not is_valid_class(Framework.constant.I_UTILITY, inter):
		push_error("This interface is not a utility interface.")
		return
	var get_framework_node = func() -> Node:
		var node = _get_node_func.call() as Node
		return node
	var context := FrameworkIUtility.Context.new(self, _logger, get_framework_node)
	ins = _get_instance(ins)
	ins.set_context(context)
	_containers.set(inter, ins)
	return ins

func _get_instance(ins: Object) -> Object:
	if "new" in ins:
		return ins.new()
	return ins