## 路由器
extends RefCounted

var history: Array[Route]

var _node: Node

var current_route:
	get():
		if _current_route_index < 0:
			return null
		return history[_current_route_index]

var _current_route_index: int = -1

var _m: Dictionary[String, Route]

func _init(node: Node) -> void:
	_node = node

func register(name: String, path: String):
	if _m.has(name):
		push_warning("There are conflicting route names.")
		return
	var route = _m.get_or_add(name, Route.new()) as Route
	route.name = name
	route.path = path
	_m.set(name, route)

func get_registered_size() -> int:
	return len(_m)

class Route:
	var name := ""
	var path := ""
	
	func _to_string() -> String:
		return "name: {0}, path: {1}".format([name, path])

func go(step: int) -> Error:
	if step == 0:
		_node.get_tree().reload_current_scene()
		return OK
	if _current_route_index + step >= len(history):
		push_warning("There is no valid route.")
		return FAILED
	_current_route_index += step
	return _change_scene(current_route.path)

func push(name: String, is_record: bool = true, is_jump: bool = true) -> Error:
	if not _m.has(name):
		push_error("The route name that does not exist.")
		return FAILED
	var route = _m.get(name)
	if is_record:
		_current_route_index += 1
		history.resize(_current_route_index + 1)
		history[_current_route_index] = route
	if is_jump:
		return _change_scene(route.path)
	return OK

func back() -> Error:
	if _current_route_index <= 0:
		push_warning("There is no valid route.")
		return FAILED
	_current_route_index -= 1
	return _change_scene(current_route.path)

func _change_scene(path: String) -> Error:
	var err = _node.get_tree().change_scene_to_file(path)
	if err != OK:
		push_error("Unable to navigate to the route, error code {0}.".format([err]))
		return err
	return OK
