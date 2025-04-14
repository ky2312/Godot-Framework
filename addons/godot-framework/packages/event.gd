## 事件管理
class_name FrameworkEvent
	
var _m: Dictionary[String, Array]

var _ready_trigger_data_cached: Dictionary[String, Variant]

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

## 发送事件
## 会压缩短时间内的事件数量
func trigger(key: String, value):
	if not _m.has(key):
		return
	_ready_trigger_data_cached.set(key, value)

## 发送事件
## 立即发送事件
func immediate_trigger(key: String, value):
	if not _m.has(key):
		return
	for callback in _m.get(key):
		callback.callv([value])

## 帧更新
func update():
	if len(_ready_trigger_data_cached) == 0:
		return
	for key in _ready_trigger_data_cached:
		var value = _ready_trigger_data_cached[key]
		for callback in _m.get(key):
			callback.callv([value])
	_ready_trigger_data_cached.clear()

func get_only_register_event() -> OnlyRegisterEvent:
	return OnlyRegisterEvent.new(self)

func get_only_trigger_event() -> OnlyTriggerEvent:
	return OnlyTriggerEvent.new(self)

class OnlyRegisterEvent:
	var _eventbus: FrameworkEvent

	func _init(eventbus: FrameworkEvent) -> void:
		self._eventbus = eventbus

	func register(key: String, callback: Callable):
		return _eventbus.register(key, callback)

	func unregister(key: String, callback: Callable):
		return _eventbus.register(key, callback)
	
class OnlyTriggerEvent:
	var _eventbus: FrameworkEvent

	func _init(eventbus: FrameworkEvent) -> void:
		self._eventbus = eventbus

	func trigger(key: String, value):
		return _eventbus.trigger(key, value)
