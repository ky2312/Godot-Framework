## 框架主体类
class_name Framework extends Node

const ISystem = preload("res://addons/godot-framework/packages/interfaces/i_system.gd")
const IModel = preload("res://addons/godot-framework/packages/interfaces/i_model.gd")
const ICommand = preload("res://addons/godot-framework/packages/interfaces/i_command.gd")
const IUtility = preload("res://addons/godot-framework/packages/interfaces/i_utility.gd")
const constant = preload("res://addons/godot-framework/constant.gd")
const BindableProperty = preload("res://addons/godot-framework/packages/bindable_property.gd")
const UnRegisterExtension = preload("res://addons/godot-framework/packages/unregister_extension.gd")

var inited: bool = false

var node: Node

var _container: Dictionary

var eventbus: EventUtility

var logger: LoggerUtility

var router: RouterUtility

var audio: AudioUtility

var game_archive: GameArchiveUtility
	
func _init() -> void:
	_register_default_containers()

func _register_default_containers():
	register_utility(LoggerUtility)
	self.logger = get_utility(LoggerUtility) as LoggerUtility
	
	register_utility(EventUtility)
	self.eventbus = get_utility(EventUtility) as EventUtility
	
	register_utility(GameArchiveUtility)
	self.game_archive = get_utility(GameArchiveUtility) as GameArchiveUtility
	
	register_utility(AudioUtility)
	self.audio = get_utility(AudioUtility) as AudioUtility

	register_utility(RouterUtility)
	self.router = get_utility(RouterUtility) as RouterUtility
	
## 注册系统层实例
func register_system(system_class: Object) -> ISystem:
	if _container.has(system_class):
		push_error("Cannot register a system class with the same name.")
		return
	var ins = _is_valid_class("ISystem", system_class)
	if not ins:
		push_error("This class is not a system class.")
		return
	_container.set(system_class, ins)
	return ins

## 获取系统层实例
func get_system(system_class: Object) -> ISystem:
	if not _container.has(system_class):
		push_error("Cannot get a system class with the name.")
		return
	return _container.get(system_class)

## 注册模型层实例
func register_model(model_class: Object) -> IModel:
	if _container.has(model_class):
		push_error("Cannot register a model class with the same name.")
		return
	var ins = _is_valid_class("IModel", model_class)
	if not ins:
		push_error("This class is not a model class.")
		return
	_container.set(model_class, ins)
	return ins

## 获取模型层实例
func get_model(model_class: Object) -> IModel:
	if not _container.has(model_class):
		push_error("Cannot get a model class with the name.")
		return
	return _container.get(model_class)

## 注册工具层实例
func register_utility(utility_class: Object) -> IUtility:
	if _container.has(utility_class):
		push_error("Cannot register a utility class with the same name.")
		return
	var ins = _is_valid_class("IUtility", utility_class)
	if not ins:
		push_error("This class is not a utility class.")
		return
	_container.set(utility_class, ins)
	return ins

## 获取工具层实例
func get_utility(utility_class: Object) -> IUtility:
	if not _container.has(utility_class):
		push_error("Cannot get a utility class with the name.")
		return
	return _container.get(utility_class)

## 发送命令
func send_command(command: ICommand):
	command.app = self
	command.on_execute()

func get_models() -> Array[IModel]:
	var models: Array[IModel]
	var container = _container
	for cls in container:
		var ins = container[cls]
		if ins.get_meta("class_name") == "IModel":
			models.push_back(ins)
	return models

## 开始运行框架
## 会检测配置是否正确
func run(node: Node) -> Error:
	if inited:
		return OK
	
	self.node = node

	_check_run()
	_init_container()
	
	inited = true
	return OK

## 结束
func quit():
	self.node.get_tree().quit()

func _is_valid_class(cls_name: String, cls: Object):
	if not "new" in cls:
		return
	# 不要在模块内使用_init(), 而是使用on_init()
	var ins = cls.new()
	if !(ins.has_meta("class_name") and ins.get_meta("class_name") == cls_name):
		return
	return ins

func _check_run():
	if router:
		if not router.get_registered_size() > 0:
			push_error("At least one route must be registered.")
			return FAILED

func _init_container():
	var valid_class_name = ["ISystem", "IModel", "IUtility"]
	for key in _container:
		if valid_class_name.has(_container[key].get_meta("class_name")):
			_container[key].app = self
			_container[key].on_init()
