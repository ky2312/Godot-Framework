## 日志
class_name FrameworkLogger extends RefCounted

## 日志等级
enum LEVEL {
	ERROR,
	WARNING,
	INFO,
	DEBUG,
}

var level: LEVEL = LEVEL.WARNING

var formatter: Formatter = Formatter.new()

var renderers: Array[Renderer] = [ConsoleRenderer.new()]

var _root_logger: SubLogger

func _init(theme: String = "Logger") -> void:
	_root_logger = SubLogger.new(self, theme)

func error(content):
	return _root_logger.error(content)

func warning(content):
	return _root_logger.warning(content)

func info(content):
	return _root_logger.info(content)

func debug(content):
	return _root_logger.debug(content)

func set_level(level: LEVEL):
	self.level = level

func set_formatter(formatter: Formatter):
	self.formatter = formatter

func add_renderer(renderer: Renderer):
	self.renderers.push_back(renderer)

func create_logger(theme: String) -> SubLogger:
	return SubLogger.new(self, theme)

class SubLogger:
	var _parent: FrameworkLogger
	
	var theme: String

	func _init(parent: FrameworkLogger, theme: String = "Logger") -> void:
		self.theme = theme
		self._parent = parent

	func error(content):
		if _parent.level < LEVEL.ERROR:
			return
		_build(LEVEL.ERROR, content)

	func warning(content):
		if _parent.level < LEVEL.WARNING:
			return
		_build(LEVEL.WARNING, content)

	func info(content):
		if _parent.level < LEVEL.INFO:
			return
		_build(LEVEL.INFO, content)
		
	func debug(content):
		if _parent.level < LEVEL.DEBUG:
			return
		_build(LEVEL.DEBUG, content)
		
	func _build(level: LEVEL, content):
		var log := Log.new(level, theme, content)
		for renderer in _parent.renderers:
			renderer.build(log, _parent.formatter)

class Log:
	var level: LEVEL
	var theme: String
	var time: String
	var content: String
	
	func _init(level: LEVEL, theme: String, content: String) -> void:
		self.level = level
		self.theme = theme
		self.time = Time.get_datetime_string_from_system()
		self.content = content

## 格式化器
## 日志的样式
class Formatter:
	var _content: String
	
	func _init(content: String = "[{time}][{level_name}]{theme}: {content}") -> void:
		self._content = content
	
	func format(log: Log) -> String:
		var level_name = _get_level_name(log.level)
		return _content.format({
			"level_name": level_name,
			"theme": log.theme,
			"time": log.time,
			"content": log.content + "\n",
		})
		
	func _get_level_name(level: LEVEL):
		match level:
			LEVEL.ERROR:
				return "error"
			LEVEL.WARNING:
				return "warning"
			LEVEL.INFO:
				return "info"
			LEVEL.DEBUG:
				return "debug"

## 渲染器
## 渲染到什么地方
class Renderer:
	func build(log: Log, formatter: Formatter) -> void:
		pass

## 控制台渲染器
class ConsoleRenderer extends Renderer:
	func build(log: Log, formatter: Formatter) -> void:
		var str = formatter.format(log)
		match log.level:
			LEVEL.ERROR:
				push_error(str)
			LEVEL.WARNING:
				push_warning(str)
			LEVEL.INFO:
				print(str)
			LEVEL.DEBUG:
				print(str)

## 文件渲染器
class FileRenderer extends Renderer:
	func build(log: Log, formatter: Formatter) -> void:
		var t = Time.get_datetime_dict_from_system()
		var file_dir := "user://game/logs/"
		var file_name := "{0}-{1}-{2}.log".format([t.year, t.month, t.day])
		var file_path := file_dir + file_name
		var file := FileAccess.open(file_path, FileAccess.ModeFlags.READ_WRITE)
		if file:
			file.seek_end()
		else:
			var err = DirAccess.make_dir_recursive_absolute(file_dir)
			if err:
				push_error("Cannot create directory: {0}.".format([err]))
				return
			file = FileAccess.open(file_path, FileAccess.ModeFlags.WRITE)
		if !file:
			push_error("Cannot open file: {0}.".format([FileAccess.get_open_error()]))
			return
		var str = formatter.format(log)
		file.store_string(str)
		file.close()
