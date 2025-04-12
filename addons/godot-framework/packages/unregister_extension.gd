## 卸载扩展
class_name FrameworkUnRegisterExtension extends RefCounted

var _callback: Callable

var _event: FrameworkEvent

var _event_name: String

func _init(event: FrameworkEvent, event_name: String, callback: Callable) -> void:
	_callback = callback
	_event = event
	_event_name = event_name

func unregister():
	_event.unregister(_event_name, _callback)

func unregister_when_node_exit_tree(node: Node):
	node.tree_exiting.connect(
		func():
			_event.unregister(_event_name, _callback)
	)
