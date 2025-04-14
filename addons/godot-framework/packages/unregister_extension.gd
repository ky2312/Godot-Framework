## 卸载扩展
class_name FrameworkUnRegisterExtension

var _callback: Callable

var _event: FrameworkEvent

var _event_name: String

var _immediate_trigger: bool

func _init(event: FrameworkEvent, event_name: String, callback: Callable, immediate: bool = false) -> void:
	_callback = callback
	_event = event
	_event_name = event_name
	_immediate_trigger = immediate

func unregister():
	_event.unregister(_event_name, _callback)
	var data = [Framework.constant.EVENT_UNREGISTERED, _event_name]
	if _immediate_trigger:
		_event.immediate_trigger.callv(data)
	else:
		_event.trigger.callv(data)

func unregister_when_node_exit_tree(node: Node):
	node.tree_exiting.connect(
		func():
			self.unregister()
	)
