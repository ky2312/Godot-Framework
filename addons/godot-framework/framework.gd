## 框架主体类
class_name Framework extends Node

const constant = preload("res://addons/godot-framework/packages/constant.gd")

var inited: bool = false

var node: Node

var _ioc: IoC

var eventbus: FrameworkEvent.RegistrableEvent
var _eventbus: FrameworkEvent

var logger: FrameworkLogger

var router: RouterUtility

var audio: AudioUtility

var game_archive: GameArchiveSystem
	
func _init() -> void:
	_init_when_init_lifecycle()
	_register_default_containers()

func _init_when_init_lifecycle():
	self._eventbus = FrameworkEvent.new()
	self.eventbus = _eventbus.get_registrable_event()
	self.logger = FrameworkLogger.new()
	var get_node_func = func() -> Node:
		return node
	self._ioc = IoC.new(_eventbus, logger, get_node_func)

func _register_default_containers():
	_ioc.register_utility(CfgStorageUtility)
	_ioc.register_utility(CsvStorageUtility)
	_ioc.register_utility(JsonStorageUtility)

	_ioc.register_utility(AudioUtility)
	self.audio = _ioc.get_utility(AudioUtility)

	_ioc.register_utility(RouterUtility)
	self.router = _ioc.get_utility(RouterUtility)

	_ioc.register_system(GameArchiveSystem)
	self.game_archive = _ioc.get_system(GameArchiveSystem)
	
## 注册系统层实例
func register_system(cls: Object) -> FrameworkISystem:
	return _ioc.register_system(cls)

## 注册模型层实例
func register_model(cls: Object) -> FrameworkIModel:
	return _ioc.register_model(cls)

## 获取模型层实例
func get_model(cls: Object) -> FrameworkIModel:
	return _ioc.get_model(cls)

## 注册工具层实例
func register_utility(cls: Object) -> FrameworkIUtility:
	return _ioc.register_utility(cls)

## 发送命令
func send_command(command: FrameworkICommand):
	var context := FrameworkICommand.Context.new(_ioc, logger)
	command.set_context(context)
	command.on_execute()

## 开始运行框架
## 会检测配置是否正确
func run(node: Node) -> Error:
	if inited:
		return OK
	
	self.node = node

	_check_run()
	_ioc.init()
	
	inited = true
	return OK

## 结束
func quit():
	self.logger.info("Quit game.")
	self.node.get_tree().quit()

func _check_run():
	if router:
		if not router.get_registered_size() > 0:
			push_error("At least one route must be registered.")
			return FAILED
