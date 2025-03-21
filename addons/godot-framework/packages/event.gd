## 事件管理类
extends RefCounted
	
var _m: Dictionary[String, Array]

func register(key: String, callback: Callable):
	var arr = _m.get_or_add(key, []) as Array
	arr.push_back(callback)
	return Framework.UnRegisterExtension.new(self, key, callback)

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
