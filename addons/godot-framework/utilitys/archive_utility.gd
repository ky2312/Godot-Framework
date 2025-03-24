class_name ArchiveUtility extends FrameworkIUtility

func on_init():
	pass

func load(path: String):
	return _load(path)

func load_encrypted(path: String, key: PackedByteArray):
	return _load(path, key)

func load_encrypted_pass(path: String, password: String):
	return _load(path, [], password)
	
func _load(path: String, key: PackedByteArray = [], password: String = "") -> Error:
	var models = self.app.get_models()
	var base_data := {}
	var config = ConfigFile.new()
	var err: Error
	if len(key) != 0:
		err = config.load_encrypted(path, key)
	elif password:
		err = config.load_encrypted_pass(path, password)
	else:
		err = config.load(path)
	if err:
		push_error("Load failed.")
		return err
	for section in config.get_sections():
		var data := {}
		for k in config.get_section_keys(section):
			data.set(k, config.get_value(section, k))
		base_data.set(section, data)
		
	_set_base_data(base_data, models)
	self.app.logger.info("Load archive success")
	return OK

func save(path: String):
	return _save(path)

func save_encrypted(path: String, key: PackedByteArray):
	return _save(path, key)

func save_encrypted_pass(path: String, password: String):
	return _save(path, [], password)
	
func _save(path: String, key: PackedByteArray = [], password: String = "") -> Error:
	var models = self.app.get_models()
	var base_data := _get_base_data(models)
	var _parsed_path = _parse_path(path)
	var dir = _parsed_path[0]
	var file_name = _parsed_path[1]
	if !file_name:
		push_error("Save archive path error.")
		return ERR_UNAVAILABLE
	
	var config = ConfigFile.new()
	for section in base_data:
		for k in base_data[section]:
			config.set_value(section, k, base_data[section][k])
			
	var err = DirAccess.make_dir_recursive_absolute(dir)
	if err:
		push_error("Cannot create directory: {0}.".format([err]))
		return ERR_UNAVAILABLE
	
	if len(key) != 0:
		err = config.save_encrypted(path, key)
	elif password:
		err = config.save_encrypted_pass(path, password)
	else:
		err = config.save(path)
	if err:
		push_error("Save failed.")
		return err
	self.app.logger.info("Save archive success")
	return OK
	
func _get_base_data(models: Array[FrameworkIModel]) -> Dictionary:
	var base_data := {}
	var re = RegEx.new()
	re.compile("(\\w+)_model.gd$")
	for model in models:
		var pl := model.get_property_list()
		var section_name := ""
		var section := {}
		for o in pl:
			if o.type == Variant.Type.TYPE_NIL:
				var result = re.search(o.name)
				if result:
					section_name = result.get_string(1)
					break
		if !section_name:
			break
		for o in pl:
			var property = model.get(o.name)
			if property and property is FrameworkBindableProperty:
				section.set(o.name, model[o.name].value)
		base_data.set(section_name, section)
	return base_data

func _set_base_data(base_data: Dictionary, models: Array[FrameworkIModel]):
	var re = RegEx.new()
	re.compile("(\\w+)_model.gd$")
	for model in models:
		var pl := model.get_property_list()
		var section_name := ""
		for o in pl:
			if o.type == Variant.Type.TYPE_NIL:
				var result = re.search(o.name)
				if result:
					section_name = result.get_string(1)
					break
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
