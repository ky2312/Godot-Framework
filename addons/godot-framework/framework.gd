## 框架主体类
class_name Framework extends RefCounted

const ISystem = preload("res://addons/godot-framework/packages/interfaces/i_system.gd")
const IModel = preload("res://addons/godot-framework/packages/interfaces/i_model.gd")
const ICommand = preload("res://addons/godot-framework/packages/interfaces/i_command.gd")
const IUtility = preload("res://addons/godot-framework/packages/interfaces/i_utility.gd")
const BindableProperty = preload("res://addons/godot-framework/packages/bindable_property.gd")
const UnRegisterExtension = preload("res://addons/godot-framework/packages/unregister_extension.gd")
const Router = preload("res://addons/godot-framework/packages/router.gd")
const Event = preload("res://addons/godot-framework/packages/event.gd")

var eventbus: Event = Event.new()

var inited: bool = false

## 路由模块需要执行enable_router才有效
var router: Router

var enabled_router: bool:
	get():
		return !!router

## 模块管理
var _modules: Dictionary

## 注册系统层实例
func register_system(system_class: Object) -> ISystem:
	if _modules.has(system_class):
		push_error("Cannot register a system class with the same name.")
		return
	var ins = _is_valid_class("ISystem", system_class)
	if not ins:
		push_error("This class is not a system class.")
		return
	_modules.set(system_class, ins)
	return ins

## 获取系统层实例
func get_system(system_class: Object) -> ISystem:
	if not _modules.has(system_class):
		push_error("Cannot get a system class with the name.")
		return
	return _modules.get(system_class)

## 注册模型层实例
func register_model(model_class: Object) -> IModel:
	if _modules.has(model_class):
		push_error("Cannot register a model class with the same name.")
		return
	var ins = _is_valid_class("IModel", model_class)
	if not ins:
		push_error("This class is not a model class.")
		return
	_modules.set(model_class, ins)
	return ins

## 获取模型层实例
func get_model(model_class: Object) -> IModel:
	if not _modules.has(model_class):
		push_error("Cannot get a model class with the name.")
		return
	return _modules.get(model_class)

## 注册工具层实例
func register_utility(utility_class: Object) -> IUtility:
	if _modules.has(utility_class):
		push_error("Cannot register a utility class with the same name.")
		return
	var ins = _is_valid_class("IUtility", utility_class)
	if not ins:
		push_error("This class is not a utility class.")
		return
	_modules.set(utility_class, ins)
	return ins

## 获取工具层实例
func get_utility(utility_class: Object) -> IUtility:
	if not _modules.has(utility_class):
		push_error("Cannot get a utility class with the name.")
		return
	return _modules.get(utility_class)

## 发送命令
func send_command(command: ICommand):
	command.app = self
	command.on_execute()

## 开启路由器
## 它会把window节点绑定到路由器上
func enable_router(window: Window):
	router = Router.new(window)

## 开始运行框架
## 会检测配置是否正确
func run():
	if inited:
		return
	if enabled_router:
		if not router.main_route_name:
			push_error("The main route has not been set. Please use router.set_main_route_name().")
			return
	var valid_class_name = ["ISystem", "IModel", "IUtility"]
	for key in _modules:
		if valid_class_name.has(_modules[key].get_meta("class_name")):
			_modules[key].app = self
			_modules[key].on_init()
	inited = true

func _is_valid_class(cls_name: String, cls: Object):
	if not "new" in cls:
		return
	var ins = cls.new()
	if !(ins.has_meta("class_name") and ins.get_meta("class_name") == cls_name):
		return
	return ins
