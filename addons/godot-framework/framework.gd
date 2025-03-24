## 框架主体类
class_name Framework extends Node

const ISystem = preload("res://addons/godot-framework/packages/interfaces/i_system.gd")
const IModel = preload("res://addons/godot-framework/packages/interfaces/i_model.gd")
const ICommand = preload("res://addons/godot-framework/packages/interfaces/i_command.gd")
const IUtility = preload("res://addons/godot-framework/packages/interfaces/i_utility.gd")
const BindableProperty = preload("res://addons/godot-framework/packages/bindable_property.gd")
const UnRegisterExtension = preload("res://addons/godot-framework/packages/unregister_extension.gd")
const Router = preload("res://addons/godot-framework/packages/router.gd")
const Event = preload("res://addons/godot-framework/packages/event.gd")
const Audio = preload("res://addons/godot-framework/packages/audio.gd")
const Logger = preload("res://addons/godot-framework/packages/logger.gd")

var inited: bool = false

var node: Node

var _container: Dictionary

## 场景被重置
const EVENT_NAME_RELOADED_SCENE = "RELOADED_SCENE"
var eventbus: Event = Event.new()

var logger: Logger = Logger.new()

## 路由模块需要调用enable_router才有效
var router: Router
var enabled_router := false

## 音频管理器模块需要调用enable_audio才有效
var audio: Audio
var enabled_audio := false

func _init() -> void:
	pass

## 注册系统层实例
func register_system(system_class: Object) -> ISystem:
	if _container.has(system_class):
		logger.error("Cannot register a system class with the same name.")
		return
	var ins = _is_valid_class("ISystem", system_class)
	if not ins:
		logger.error("This class is not a system class.")
		return
	_container.set(system_class, ins)
	return ins

## 获取系统层实例
func get_system(system_class: Object) -> ISystem:
	if not _container.has(system_class):
		logger.error("Cannot get a system class with the name.")
		return
	return _container.get(system_class)

## 注册模型层实例
func register_model(model_class: Object) -> IModel:
	if _container.has(model_class):
		logger.error("Cannot register a model class with the same name.")
		return
	var ins = _is_valid_class("IModel", model_class)
	if not ins:
		logger.error("This class is not a model class.")
		return
	_container.set(model_class, ins)
	return ins

## 获取模型层实例
func get_model(model_class: Object) -> IModel:
	if not _container.has(model_class):
		logger.error("Cannot get a model class with the name.")
		return
	return _container.get(model_class)

## 注册工具层实例
func register_utility(utility_class: Object) -> IUtility:
	if _container.has(utility_class):
		logger.error("Cannot register a utility class with the same name.")
		return
	var ins = _is_valid_class("IUtility", utility_class)
	if not ins:
		logger.error("This class is not a utility class.")
		return
	_container.set(utility_class, ins)
	return ins

## 获取工具层实例
func get_utility(utility_class: Object) -> IUtility:
	if not _container.has(utility_class):
		logger.error("Cannot get a utility class with the name.")
		return
	return _container.get(utility_class)

## 发送命令
func send_command(command: ICommand):
	command.app = self
	command.on_execute()

## 开启路由器
func enable_router():
	enabled_router = true

## 开启音频管理器
func enable_audio():
	enabled_audio = true

func reload_scene():
	node.get_tree().reload_current_scene()
	logger.info("reloaded scene")
	eventbus.trigger(EVENT_NAME_RELOADED_SCENE, null)

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
func run(node: Node):
	if inited:
		return
	
	if enabled_router:
		router = Router.new(node)
	if enabled_audio:
		audio = Audio.new(node)
	
	# 加载默认模块
	register_utility(ArchiveUtility)
	
	var valid_class_name = ["ISystem", "IModel", "IUtility"]
	for key in _container:
		if valid_class_name.has(_container[key].get_meta("class_name")):
			_container[key].app = self
			_container[key].on_init()
	
	self.node = node
	inited = true

func _is_valid_class(cls_name: String, cls: Object):
	if not "new" in cls:
		return
	# 不要在模块内使用_init(), 而是使用on_init()
	var ins = cls.new()
	if !(ins.has_meta("class_name") and ins.get_meta("class_name") == cls_name):
		return
	return ins
