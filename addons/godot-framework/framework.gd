## 框架主体类
class_name Framework extends Node

const ISystem = preload("res://addons/godot-framework/packages/interfaces/i_system.gd")
const IModel = preload("res://addons/godot-framework/packages/interfaces/i_model.gd")
const ICommand = preload("res://addons/godot-framework/packages/interfaces/i_command.gd")
const IUtility = preload("res://addons/godot-framework/packages/interfaces/i_utility.gd")
const constant = preload("res://addons/godot-framework/packages/constant.gd")
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
func register_system(cls: Object) -> ISystem:
	if _container.has(cls):
		push_error("Cannot register a system class with the same name.")
		return
	if not is_valid_class(constant.I_SYSTEM, cls):
		push_error("This class is not a system class.")
		return
	var ins = cls.new()
	_container.set(cls, ins)
	return ins

## 获取系统层实例
func get_system(cls: Object) -> ISystem:
	if not _container.has(cls):
		push_error("Cannot get a system class with the name.")
		return
	return _container.get(cls)

## 注册模型层实例
func register_model(cls: Object) -> IModel:
	if _container.has(cls):
		push_error("Cannot register a model class with the same name.")
		return
	if not is_valid_class(constant.I_MODEL, cls):
		push_error("This class is not a model class.")
		return
	var ins = cls.new()
	_container.set(cls, ins)
	return ins

## 获取模型层实例
func get_model(cls: Object) -> IModel:
	if not _container.has(cls):
		push_error("Cannot get a model class with the name.")
		return
	return _container.get(cls)

## 注册工具层实例
func register_utility(cls: Object) -> IUtility:
	if _container.has(cls):
		push_error("Cannot register a utility class with the same name.")
		return
	if not is_valid_class(constant.I_UTILITY, cls):
		push_error("This class is not a utility class.")
		return
	var ins = cls.new()
	_container.set(cls, ins)
	return ins

## 获取工具层实例
func get_utility(cls: Object) -> IUtility:
	if not _container.has(cls):
		push_error("Cannot get a utility class with the name.")
		return
	return _container.get(cls)

## 发送命令
func send_command(command: ICommand):
	command.app = self
	command.on_call()

## 开始运行框架
## 会检测配置是否正确
func run(node: Node) -> Error:
	if inited:
		return OK
	
	self.node = node

	_check_run()
	_init_containers()
	
	inited = true
	return OK

## 结束
func quit():
	self.node.get_tree().quit()

static func is_valid_class(cls_id: String, cls: Object) -> bool:
	if not "new" in cls:
		return false
	if not cls.class_id == cls_id:
		return false
	return true

func _check_run():
	if router:
		if not router.get_registered_size() > 0:
			push_error("At least one route must be registered.")
			return FAILED

func _init_containers():
	var valid_class_id = [constant.I_SYSTEM, constant.I_MODEL, constant.I_UTILITY]
	for key in _container:
		if valid_class_id.has(_container[key].class_id):
			_container[key].app = self
			_container[key].on_init()
