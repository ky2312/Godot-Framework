## 框架主体类
class_name Framework extends Node

const constant = preload("res://addons/godot-framework/packages/constant.gd")

var inited: bool = false

var node: Node

var _ioc: IoC

var eventbus: FrameworkEvent.OnlyRegisterEvent
var full_eventbus: FrameworkEvent:
	get(): return _full_eventbus
var _full_eventbus: FrameworkEvent

var logger: FrameworkLogger

var router: RouterUtilityNS.IRouterUtility

var audio: AudioUtilityNS.IAudioUtility

var game_archive: GameArchiveSystemNS.IGameArchiveSystem
	
func _init() -> void:
	_init_when_init_lifecycle()
	_register_default_containers()

func _init_when_init_lifecycle():
	self._full_eventbus = FrameworkEvent.new()
	self.eventbus = _full_eventbus.get_only_register_event()
	self.logger = FrameworkLogger.new()
	var get_node_func = func() -> Node:
		return node
	self._ioc = IoC.new(_full_eventbus, logger, get_node_func)

func _init_when_ready_lifecycle():
	self.audio = _ioc.get_container(AudioUtilityNS.IAudioUtility)
	self.router = _ioc.get_container(RouterUtilityNS.IRouterUtility)
	self.game_archive = _ioc.get_container(GameArchiveSystemNS.IGameArchiveSystem)

func _register_default_containers():
	var storage_utility = _ioc.register_container(StorageUtilityNS.IStorageUtility, StorageUtilityNS.StorageUtility.new())
	_ioc.register_container(AudioUtilityNS.IAudioUtility, AudioUtilityNS.AudioUtility.new())
	_ioc.register_container(RouterUtilityNS.IRouterUtility, RouterUtilityNS.RouterUtility.new())
	_ioc.register_container(GameArchiveSystemNS.IGameArchiveSystem, GameArchiveSystemNS.GameArchiveSystem.new(storage_utility))

func register_container(inter: Object, ins: Object) -> Object:
	return _ioc.register_container(inter, ins)

func get_container(inter: Object) -> Object:
	return _ioc.get_container(inter)

func unregister_container(inter: Object):
	return _ioc.unregister_container(inter)

## 发送命令
func send_command(command: FrameworkICommand):
	var context := FrameworkICommand.Context.new(_ioc, logger)
	command.set_context(context)
	command.on_execute()

## 开始运行框架
func run(node: Node) -> Error:
	if inited:
		return OK
	
	self.node = node
	self._init_when_ready_lifecycle()
	self._ioc.build()
	
	inited = true
	return OK

## 帧更新
func update(delta: float) -> void:
	_full_eventbus.update()

## 结束
func quit():
	self.logger.info("Quit game.")
	self.node.get_tree().quit()
