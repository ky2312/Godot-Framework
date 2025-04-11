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
		return get_value()
	
	set(value):
		set_value(value)
		_observer.trigger(value)

func get_value():
	return _value

func set_value(value):
	_value = value

func register(callback: Callable):
	_observer.register(callback)
	return Framework.UnRegisterExtension.new(_observer.event, _observer.event_name, callback)

func register_with_init_value(callback: Callable):
	callback.callv([value])
	register(callback)
	return Framework.UnRegisterExtension.new(_observer.event, _observer.event_name, callback)

static func register_with_init_value_wait_unregister(node: Node, bindablePropertys: Array[FrameworkBindableProperty], callback: Callable):
	var values := []
	for i in range(len(bindablePropertys)):
		var b = bindablePropertys[i]
		values.push_back(b.value)
		b.register_with_init_value(
			func(v):
				values[i] = v
				callback.callv(values)
		).unregister_when_node_exit_tree(node)

func unregister(callback: Callable):
	Framework.UnRegisterExtension.new(_observer.event, _observer.event_name, callback).unregister()

## 观察属性的观察者
class Observer:
	var event:
		get(): return _event
	var _event := EventUtility.new()
	
	var _event_name := "value_change"
	var event_name:
		get(): return _event_name

	func register(callback: Callable):
		_event.register(_event_name, callback)
	
	func unregister(callback: Callable):
		_event.unregister(_event_name, callback)
	
	func trigger(value):
		_event.trigger(_event_name, value)
