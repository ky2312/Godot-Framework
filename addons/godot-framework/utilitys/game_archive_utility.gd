## 存档
class_name GameArchiveUtility extends FrameworkIUtility

var _path: String

var _secret_key: String

var _models: Dictionary[String, Object]

func on_init():
	for k in _models:
		var cls = _models.get(k)
		if not Framework.is_valid_class(Framework.constant.I_MODEL, cls):
			self.app.logger.warning("The registered class must be a model, class id is {0}.".format([k]))
			return

func configuration(path: String, secret_key: String) -> void:
	self._path = path
	self._secret_key = secret_key

func register_model(name: String, cls: Object):
	self._models.set(name, cls)

func save():
	if _check() != OK:
		return
	var base_data := _get_base_data(_models)
	var _parsed_path = _parse_path(_path)
	var dir = _parsed_path[0]
	var file_name = _parsed_path[1]
	if !file_name:
		self.app.logger.error("Save archive path error.")
		return FAILED
	
	var config = ConfigFile.new()
	for section in base_data:
		for k in base_data[section]:
			config.set_value(section, k, base_data[section][k])
			
	var err = DirAccess.make_dir_recursive_absolute(dir)
	if err:
		self.app.logger.error("Cannot create directory: {0}.".format([err]))
		return FAILED
	
	if _secret_key:
		err = config.save_encrypted_pass(_path, _secret_key)
	else:
		err = config.save(_path)
	if err:
		self.app.logger.error("Save failed.")
		return err
	self.app.logger.info("Save archive success")
	return OK

func _get_base_data(models: Dictionary[String, Object]) -> Dictionary:
	var base_data := {}
	for model_key in models:
		var model_class := models.get(model_key)
		var model := self.app.get_model(model_class)
		var pl := model.get_property_list()
		var section_name := model_key
		var section := {}
		if !section_name:
			break
		for o in pl:
			var property = model.get(o.name)
			if property and property is FrameworkBindableProperty:
				section.set(o.name, model[o.name].value)
		base_data.set(section_name, section)
	return base_data

func load():
	if _check() != OK:
		return
	var base_data := {}
	var config = ConfigFile.new()
	var err: Error
	if _secret_key:
		err = config.load_encrypted_pass(_path, _secret_key)
	else:
		err = config.load(_path)
	if err:
		self.app.logger.error("Load failed.")
		return err
	for section in config.get_sections():
		var data := {}
		for k in config.get_section_keys(section):
			data.set(k, config.get_value(section, k))
		base_data.set(section, data)
		
	_set_base_data(base_data, _models)
	self.app.logger.info("Load archive success")
	return OK

func _set_base_data(base_data: Dictionary, models: Dictionary[String, Object]):
	for model_key in models:
		var model_class := models.get(model_key)
		var model := self.app.get_model(model_class)
		var pl := model.get_property_list()
		var section_name := model_key
		if !section_name:
			break
		if !base_data.has(section_name):
			break
		var section = base_data.get(section_name)
		for key in section:
			if model[key] is FrameworkBindableProperty:
				model[key].value = section[key]

func _parse_path(path: String) -> Array:
	var dir = ""
	var file_name = ""
	var last_index = path.rfind("/")
	if last_index != -1:
		dir = path.left(last_index)
		file_name = path.right(len(path) - last_index - 1)
	return [dir, file_name]

func _check() -> Error:
	if not _path:
		self.app.logger.error("The path must be set.")
		return FAILED
	if len(_models) == 0:
		self.app.logger.warning("There is no model data that needs to be saved.")
		return FAILED
	return OK
