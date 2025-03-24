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

var _container: Dictionary

## 场景被重置
const EVENT_NAME_RELOADED = "RELOADED"
var eventbus: Event = Event.new()

var logger: Logger = Logger.new()

## 路由模块需要调用enable_router才有效
var router: Router

## 音频管理器模块需要调用enable_audio才有效
var audio: Audio

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
func enable_router(node: Node):
	router = Router.new(node)

## 开启音频管理器
func enable_audio(node: Node):
	audio = Audio.new(node)

## 开始运行框架
## 会检测配置是否正确
func run():
	if inited:
		return
	if !!router:
		if not router.main_route_name:
			logger.error("The main route has not been set. Please use router.set_main_route_name().")
			return
	var valid_class_name = ["ISystem", "IModel", "IUtility"]
	for key in _container:
		if valid_class_name.has(_container[key].get_meta("class_name")):
			_container[key].app = self
			_container[key].on_init()
	inited = true

func reload(node: Node):
	node.get_tree().reload_current_scene()
	logger.info("reloaded")
	eventbus.trigger(EVENT_NAME_RELOADED, null)

func _is_valid_class(cls_name: String, cls: Object):
	if not "new" in cls:
		return
	var ins = cls.new()
	if !(ins.has_meta("class_name") and ins.get_meta("class_name") == cls_name):
		return
	return ins
