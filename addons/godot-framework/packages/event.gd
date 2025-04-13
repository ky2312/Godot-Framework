## 事件管理
class_name FrameworkEvent
	
var _m: Dictionary[String, Array]

func register(key: String, callback: Callable):
	var arr = _m.get_or_add(key, []) as Array
	arr.push_back(callback)
	return FrameworkUnRegisterExtension.new(self, key, callback)

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

func get_registrable_event() -> RegistrableEvent:
	return RegistrableEvent.new(self)

func get_triggerable_event() -> TriggerableEvent:
	return TriggerableEvent.new(self)

class RegistrableEvent:
	var _eventbus: FrameworkEvent

	func _init(eventbus: FrameworkEvent) -> void:
		self._eventbus = eventbus

	func register(key: String, callback: Callable):
		return _eventbus.register(key, callback)

	func unregister(key: String, callback: Callable):
		return _eventbus.register(key, callback)
	
class TriggerableEvent:
	var _eventbus: FrameworkEvent

	func _init(eventbus: FrameworkEvent) -> void:
		self._eventbus = eventbus

	func trigger(key: String, value):
		return _eventbus.trigger(key, value)
