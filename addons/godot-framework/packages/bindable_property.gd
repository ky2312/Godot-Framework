## 可绑定的属性类
class_name FrameworkBindableProperty extends RefCounted

## 实际的属性值
var _value

var _observer := Observer.new()

func _init(value) -> void:
	self.value = value

## 使用的属性值
var value:
	get():
		return _value
	
	set(value):
		_value = value
		_observer.trigger(value)

static func register_propertys(bindablePropertys: Array[FrameworkBindableProperty], callback: Callable) -> FrameworkUnRegisterExtension:
	var unregisters: Array[FrameworkUnRegisterExtension] = []
	var values: Array = []
	for i in range(len(bindablePropertys)):
		var b = bindablePropertys[i]
		values.push_back(b.value)
		var unregister = b.register(
			func(v):
				values[i] = v
				callback.callv(values)
		)
		unregisters.push_back(unregister)

	var _observer := Observer.new()
	var _callback = func():
		for unregister in unregisters:
			unregister.unregister()
	return FrameworkUnRegisterExtension.new(_observer.event, _observer.event_name, _callback)

static func register_propertys_with_init_value(bindablePropertys: Array[FrameworkBindableProperty], callback: Callable):
	var values = []
	for b in bindablePropertys:
		values.push_back(b.value)
	callback.callv(values)
	return FrameworkBindableProperty.register_propertys(bindablePropertys, callback)

func register(callback: Callable) -> FrameworkUnRegisterExtension:
	_observer.register(callback)
	return FrameworkUnRegisterExtension.new(_observer.event, _observer.event_name, callback)

func register_with_init_value(callback: Callable) -> FrameworkUnRegisterExtension:
	callback.callv([value])
	return register(callback)

func unregister(callback: Callable):
	FrameworkUnRegisterExtension.new(_observer.event, _observer.event_name, callback).unregister()

## 观察属性的观察者
class Observer:
	var event:
		get(): return _event
	var _event := FrameworkEvent.new()
	
	var _event_name := "value_change"
	var event_name:
		get(): return _event_name

	func register(callback: Callable):
		_event.register(_event_name, callback)
	
	func unregister(callback: Callable):
		_event.unregister(_event_name, callback)
	
	func trigger(value):
		_event.trigger(_event_name, value)
