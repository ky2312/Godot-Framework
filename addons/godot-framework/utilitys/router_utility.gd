## 路由器
class_name RouterUtility extends FrameworkIUtility

var history: Array[Route]

var current_route:
	get():
		if _current_route_index < 0:
			return null
		return history[_current_route_index]

var _current_route_index: int = -1

var _m: Dictionary[String, Route]

func register(name: String, path: String):
	if _m.has(name):
		self.app.logger.warning("There are conflicting route names.")
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
		self.app.node.get_tree().reload_current_scene()
		return OK
	if _current_route_index + step >= len(history):
		self.app.logger.warning("There is no valid route.")
		return FAILED
	_current_route_index += step
	return _change_scene(current_route.path)

func push(name: String, is_record: bool = true, is_jump: bool = true) -> Error:
	if not _m.has(name):
		self.app.logger.error("The route name that does not exist.")
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
		self.app.logger.warning("There is no valid route.")
		return FAILED
	_current_route_index -= 1
	return _change_scene(current_route.path)

func _change_scene(path: String) -> Error:
	var err = self.app.node.get_tree().change_scene_to_file(path)
	if err != OK:
		self.app.logger.error("Unable to navigate to the route, error code {0}.".format([err]))
		return err
	return OK
