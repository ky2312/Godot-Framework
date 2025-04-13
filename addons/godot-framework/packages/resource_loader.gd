## 异步加载器
class_name FrameworkResourceLoader

var _containers: Dictionary[String, LoadContainer]

## 加载
## progress_callback: (progress: float) => void
## finished_callback: (resource: Resource) => void
func load(path: String, progress_callback: Callable, finished_callback: Callable):
	var c := LoadContainer.new(path, progress_callback, finished_callback)
	_containers.set(path, c)
	ResourceLoader.load_threaded_request(path)

func update():
	var ready_remove: Array[String] = []
	for path in _containers:
		var c := _containers.get(path) as LoadContainer
		var status := ResourceLoader.load_threaded_get_status(c.path, c.progress)
		match status:
			ResourceLoader.THREAD_LOAD_IN_PROGRESS:
				c.progress_callback.callv([c.progress[0]])
			ResourceLoader.THREAD_LOAD_LOADED:
				var res := ResourceLoader.load_threaded_get(path)
				c.finished_callback.callv([res])
				ready_remove.push_back(path)

	for path in ready_remove:
		_containers.erase(path)
   
class LoadContainer:
	var path: String

	## 进度 0.0~1.0
	var progress: Array[float] = [0.0]

	var progress_callback: Callable

	var finished_callback: Callable

	func _init(path: String, progress_callback: Callable, finished_callback: Callable) -> void:
		self.path = path
		self.progress_callback = progress_callback
		self.finished_callback = finished_callback
