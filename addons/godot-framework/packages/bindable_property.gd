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
	return FrameworkUnRegisterExtension.new(_event, "_", func():)

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

# func create_readonly_bindable_property() -> ReadonlyBindableProperty:
# 	var rbp := ReadonlyBindableProperty.new(null)
# 	rbp.set_bindable_property(self)
# 	return rbp

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
	
# class ReadonlyBindableProperty extends FrameworkBindableProperty:
# 	var _bp: FrameworkBindableProperty

# 	func set_bindable_property(bp: FrameworkBindableProperty):
# 		_bp = bp
# 		_observer = bp.observer

# 	func get_value():
# 		return _bp._value

# 	func set_value(value):
# 		var message = "The read-only status cannot be modified."
# 		if GameManager and GameManager.app:
# 			GameManager.app.logger.warning(message)
# 		else:
# 			push_warning(message)