extends Node
class_name Framework

const CLASS_NAME_KEY = "class_name"
const ISYSTEM_KEY = "ISystem"
const IMODEL_KEY = "IModel"
const ICOMMAND_KEY = "ICommand"
const IUTILITY_KEY = "IUtility"

class ISystem extends RefCounted:
	## 依附的应用
	var app: App
	
	func _init() -> void:
		self.set_meta(CLASS_NAME_KEY, ISYSTEM_KEY)
	## 初始化时执行
	## 子类应该实现
	func on_init():
		pass

class IModel extends RefCounted:
	## 依附的应用
	var app: App
	
	func _init() -> void:
		self.set_meta(CLASS_NAME_KEY, IMODEL_KEY)
	## 初始化时执行
	## 子类应该实现
	func on_init():
		pass

class ICommand extends RefCounted:
	## 依附的应用
	var app: App
	
	func _init() -> void:
		self.set_meta(CLASS_NAME_KEY, ICOMMAND_KEY)
	## 命令被调用时执行
	## 子类应该实现
	func on_execute():
		pass

class IUtility extends RefCounted:
	## 依附的应用
	var app: App
	
	func _init() -> void:
		self.set_meta(CLASS_NAME_KEY, IUTILITY_KEY)
	## 初始化时执行
	## 子类应该实现
	func on_init():
		pass

## 可绑定的属性类
class BindableProperty extends RefCounted:
	## 实际的属性值
	var _value
	
	## 观察属性的观察者
	var _observer: Event = Event.new()
	
	func _init(value) -> void:
		self.value = value
	
	## 使用的属性值
	var value:
		get():
			return get_value()
		
		set(value):
			set_value(value)
			_observer.trigger("value_change", value)
	
	func get_value():
		return _value

	func set_value(value):
		_value = value
	
	func register(callback: Callable):
		_observer.register("value_change", callback)
		return UnRegisterExtension.new(_observer, "value_change", callback)
	
	func register_with_init_value(callback: Callable):
		callback.callv([value])
		register(callback)
		return UnRegisterExtension.new(_observer, "value_change", callback)

	func unregister(callback: Callable):
		UnRegisterExtension.new(_observer, "value_change", callback).unregister()

class UnRegisterExtension extends RefCounted:
	var _callback: Callable
	
	var _event: Event
	
	var _event_name: String
	
	func _init(event: Event, event_name: String, callback: Callable) -> void:
		_callback = callback
		_event = event
		_event_name = event_name

	func unregister():
		_event.unregister(_event_name, _callback)

	func unregister_when_node_exit_tree(node: Node):
		node.tree_exiting.connect(func():
			_event.unregister(_event_name, _callback)
		)

## 路由器
class Router extends RefCounted:
	var history: Array[Dictionary]
	
	var _window: Window
	
	var _main_route_name: String
	var main_route_name: String:
		get():
			return _main_route_name
	
	var current_route:
		get():
			return history[_current_route_index]
	
	var _current_route_index: int = -1
	
	var _m: Dictionary[String, Dictionary]
	
	func _init(window: Window) -> void:
		_window = window
	
	## 设置主路由(主场景)
	func set_main_route_name(name: String):
		_main_route_name = name
		push(name, true, false)
		
	func register(name: String, path: String):
		if _m.has(name):
			push_warning("There are conflicting route names.")
			return
		var route = _m.get_or_add(name, {
			"name": "",
			"path": "",
		})
		route.name = name
		route.path = path
		_m.set(name, route)
	
	func go(step: int) -> Error:
		if step == 0:
			return FAILED
		if _current_route_index + step >= len(history):
			push_warning("There is no valid route.")
			return FAILED
		_current_route_index += step
		return _change_scene(current_route.path)
	
	func push(name: String, is_record: bool = true, is_jump: bool = true) -> Error:
		if not _m.has(name):
			push_error("The route name that does not exist.")
			return FAILED
		var route = _m.get(name)
		if is_record:
			_current_route_index += 1
			history.resize(_current_route_index + 1)
			history[_current_route_index] = route
		if is_jump:
			return _change_scene(route.path)
		return OK
	
	func back() -> Error:
		if _current_route_index <= 0:
			push_warning("There is no valid route.")
			return FAILED
		_current_route_index -= 1
		return _change_scene(current_route.path)
	
	func _change_scene(path: String) -> Error:
		var err = _window.get_tree().change_scene_to_file(path)
		if err != OK:
			push_error("Unable to navigate to the route, error code {0}.".format([err]))
			return err
		return OK
	
## 事件管理类
class Event extends RefCounted:
	var _m: Dictionary[String, Array]
	
	func register(key: String, callback: Callable):
		var arr = _m.get_or_add(key, []) as Array
		arr.push_back(callback)
		return UnRegisterExtension.new(self, key, callback)
	
	func unregister(key: String, callback: Callable):
		if not _m.has(key):
			return
		var arr = _m.get(key) as Array
		arr.erase(callback)
		if len(arr) == 0:
			_m.erase(key)
	
	func trigger(key: String, value):
		if not _m.has(key):
			return
		for callback in _m.get(key):
			callback.callv([value])

## 框架主体类
class App extends RefCounted:
	var eventbus: Event = Event.new()
	
	var inited: bool = false
	
	## 路由模块需要执行enable_router才有效
	var router: Router

	var enabled_router: bool:
		get():
			return !!router
	
	## 可被管理的实例
	var _container: Dictionary
	
	## 注册系统层实例
	func register_system(system_class: Object) -> ISystem:
		if _container.has(system_class):
			push_error("Cannot register a system class with the same name.")
			return
		var ins = _is_valid_class(ISYSTEM_KEY, system_class)
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
		var ins = _is_valid_class(IMODEL_KEY, model_class)
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
		var ins = _is_valid_class(IUTILITY_KEY, utility_class)
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
		var valid_class_name = [ISYSTEM_KEY, IMODEL_KEY, IUTILITY_KEY]
		for key in _container:
			if valid_class_name.has(_container[key].get_meta(CLASS_NAME_KEY)):
				_container[key].app = self
				_container[key].on_init()
		inited = true
	
	func _is_valid_class(cls_name: String, cls: Object):
		if not "new" in cls:
			return
		var ins = cls.new()
		if !(ins.has_meta(CLASS_NAME_KEY) and ins.get_meta(CLASS_NAME_KEY) == cls_name):
			return
		return ins
