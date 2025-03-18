extends Node
class_name Framework

class ISystem:
	func _init() -> void:
		self.set_meta("class_name", "ISystem")
	## 初始化时执行
	## 子类应该实现
	func on_init():
		pass

class IModel:
	func _init() -> void:
		self.set_meta("class_name", "IModel")
	## 初始化时执行
	## 子类应该实现
	func on_init():
		pass

class ICommand:
	func _init() -> void:
		self.set_meta("class_name", "ICommand")
	## 命令被调用时执行
	## 子类应该实现
	func on_execute():
		pass

class IUtility:
	func _init() -> void:
		self.set_meta("class_name", "IUtility")
	## 初始化时执行
	## 子类应该实现
	func on_init():
		pass

## 可绑定的属性类
class BindableProperty:
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

class UnRegisterExtension:
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

## 事件管理类
class Event:
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
	
	func trigger(key: String, value: Variant):
		if not _m.has(key):
			return
		for callback in _m.get(key):
			callback.callv([value])

## 框架主体类
class App:
	## 事件总线
	var eventbus: Event = Event.new()
	
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
		command.on_execute()
	
	## 开始运行框架
	func run():
		for key in _modules:
			if _modules[key].has_method("on_init"):
				# 延迟调用，避免函数内存在调用还未完成的对象
				_modules[key].on_init.call_deferred()
	
	func _is_valid_class(cls_name: String, cls: Object):
		if not cls.has_method("new"):
			return
		var ins = cls.new()
		if !(ins.has_meta("class_name") and ins.get_meta("class_name") == cls_name):
			return
		return ins
