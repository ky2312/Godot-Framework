## 路由器
class_name RouterUtility extends FrameworkIUtility

var history: Array[Route]

var current_route:
	get():
		if _current_route_index < 0:
			return null
		return history[_current_route_index]
var _current_route_index: int = -1

var need_loading_route: Route

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
	return change_scene(current_route.path)

func push(name: String, is_record: bool = true, router_jump: RouterJump = QuickRouterJump.new()) -> Error:
	if not _m.has(name):
		self.app.logger.error("The route name that does not exist.")
		return FAILED
	var route = _m.get(name)
	if is_record:
		_current_route_index += 1
		history.resize(_current_route_index + 1)
		history[_current_route_index] = route
	router_jump.router = self
	router_jump.jump(route)
	return OK

func back() -> Error:
	if _current_route_index <= 0:
		self.app.logger.warning("There is no valid route.")
		return FAILED
	_current_route_index -= 1
	return change_scene(current_route.path)

func change_scene(path_or_packed) -> Error:
	var err: Error
	if typeof(path_or_packed) == TYPE_STRING:
		err = app.node.get_tree().change_scene_to_file(path_or_packed)
	else:
		err = app.node.get_tree().change_scene_to_packed(path_or_packed)
	if err != OK:
		app.logger.error("Unable to navigate to the route, error code {0}.".format([err]))
		return err
	return OK

## 路由器跳转
class RouterJump:
	var router: RouterUtility
	
	func jump(route: Route):
		pass

## 快速模式路由器跳转
class QuickRouterJump extends RouterJump:
	func jump(route: Route):
		router.need_loading_route = route
		router.change_scene(route.path)
		router.need_loading_route = null

## 加载模式路由器跳转
class LoadRouterJump extends RouterJump:
	var loading_path = "res://addons/godot-framework/views/route_loading/route_loading.tscn"
	
	func jump(route: Route):
		router.need_loading_route = route
		router.change_scene(loading_path)

## 加载模式路由器控制逻辑
class LoadRouterControl:
	var _progress: Array[float] = []
	
	var _scene_res: Resource

	var _update_func: Callable
	
	var _finished_func: Callable
	
	func bind_update_func(fuc: Callable):
		self._update_func = fuc
		
	func bind_finished_func(fuc: Callable):
		self._finished_func = fuc
		
	func load():
		ResourceLoader.load_threaded_request(GameManager.app.router.need_loading_route.path)

	func update():
		var status = ResourceLoader.load_threaded_get_status(GameManager.app.router.need_loading_route.path, _progress)
		match status:
			ResourceLoader.THREAD_LOAD_IN_PROGRESS:
				if _update_func:
					_update_func.callv([_progress[0] * 100])
			ResourceLoader.THREAD_LOAD_LOADED:
				if _update_func:
					_update_func.callv([_progress[0] * 100])
				_scene_res = ResourceLoader.load_threaded_get(GameManager.app.router.need_loading_route.path)
				if _finished_func:
					await _finished_func.call()
				_finish()
		
	func _finish():
		GameManager.app.router.change_scene(_scene_res)
		GameManager.app.router.need_loading_route = null
