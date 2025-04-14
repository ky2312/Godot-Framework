## 可绑定的属性类
class_name FrameworkBindableProperty

## 使用的属性值
var value:
	get():
		return get_value()
	
	set(value):
		set_value(value)
## 实际的属性值
var _value

var observer: Observer:
	get(): return _observer
var _observer := Observer.new()

func _init(value) -> void:
	self._value = value

func get_value():
	return _value

func set_value(value):
	_value = value
	_observer.trigger(value)

static func register_propertys(bindablePropertys: Array[FrameworkBindableProperty], callback: Callable) -> FrameworkUnRegisterExtension:
	var unregisters: Array[FrameworkUnRegisterExtension] = []
	var values: Array = []
	var len = len(bindablePropertys)
	for i in range(len):
		var b = bindablePropertys[i]
		values.push_back(b.value)
		var unregister = b.register(
			func(v):
				values[i] = v
				callback.callv(values)
		)
		unregisters.push_back(unregister)

	var _event := FrameworkEvent.new()
	var unregister_callback = func(_v):
		for unregister in unregisters:
			unregister.unregister()
	_event.register(Framework.constant.EVENT_UNREGISTERED, unregister_callback)
	return FrameworkUnRegisterExtension.new(_event, "_", func():, true)

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
	var _event: FrameworkEvent
	
	var _event_name := ""
	var event_name:
		get(): return _event_name

	static var _id := 0

	func _init() -> void:
		Observer._id += 1
		self._event_name = "value_change_{0}".format([Observer._id])
		var f = func():
			self._event = GameManager.app.full_eventbus
		f.call_deferred()

	func register(callback: Callable):
		var f = func():
			_event.register(_event_name, callback)
		f.call_deferred()
	
	func unregister(callback: Callable):
		var f = func():
			_event.unregister(_event_name, callback)
		f.call_deferred()
	
	func trigger(value):
		var f = func():
			_event.trigger(_event_name, value)
		f.call_deferred()
