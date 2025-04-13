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

func on_init():
	pass

func register(name: String, path: String):
	if _m.has(name):
		self.context.logger.warning("There are conflicting route names.")
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
		self.context.get_framework_node().get_tree().reload_current_scene()
		return OK
	if _current_route_index + step >= len(history):
		self.context.logger.warning("There is no valid route.")
		return FAILED
	_current_route_index += step
	return change_scene(current_route.path)

func push(name: String, is_record: bool = true, router_jump: RouterJump = QuickRouterJump.new()) -> Error:
	if not _m.has(name):
		self.context.logger.error("The route name that does not exist.")
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
		self.context.logger.warning("There is no valid route.")
		return FAILED
	_current_route_index -= 1
	return change_scene(current_route.path)

func change_scene(path_or_packed) -> Error:
	var err: Error
	if typeof(path_or_packed) == TYPE_STRING:
		err = self.context.get_framework_node().get_tree().change_scene_to_file(path_or_packed)
	else:
		err = self.context.get_framework_node().get_tree().change_scene_to_packed(path_or_packed)
	if err != OK:
		self.context.logger.error("Unable to navigate to the route, error code {0}.".format([err]))
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
	var _update_callback: Callable
	
	var _finished_callback: Callable

	var _router: RouterUtility

	var _res_loader := FrameworkResourceLoader.new()

	func _init(router: RouterUtility, update_callback: Callable, finished_callback: Callable) -> void:
		self._router = router
		self._update_callback = update_callback
		self._finished_callback = finished_callback
	
	func load():
		_res_loader.load(_router.need_loading_route.path, _update, _finish)

	func update():
		_res_loader.update()
	
	func _update(p):
		if _update_callback:
			_update_callback.callv([p * 100])

	func _finish(r):
		if _update_callback:
			_update_callback.callv([100.0])
		if _finished_callback:
			await _finished_callback.call()
		_router.change_scene(r)
		_router.need_loading_route = null
