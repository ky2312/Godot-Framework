class_name ArchiveUtility extends FrameworkIUtility

func on_init():
	pass

func load(path: String):
	_load(path)

func load_encrypted(path: String, key: PackedByteArray):
	_load(path, key)

func load_encrypted_pass(path: String, password: String):
	_load(path, [], password)
	
func _load(path: String, key: PackedByteArray = [], password: String = ""):
	var models = self.app.get_models()
	var base_data := {}
	var config = ConfigFile.new()
	if len(key) != 0:
		config.load_encrypted(path, key)
	elif password:
		config.load_encrypted_pass(path, password)
	else:
		config.load(path)
	for section in config.get_sections():
		var data := {}
		for k in config.get_section_keys(section):
			data.set(k, config.get_value(section, k))
		base_data.set(section, data)
		
	_set_base_data(base_data, models)

func save(path: String):
	_save(path)

func save_encrypted(path: String, key: PackedByteArray):
	_save(path, key)

func save_encrypted_pass(path: String, password: String):
	_save(path, [], password)

func _save(path: String, key: PackedByteArray = [], password: String = ""):
	var models = self.app.get_models()
	var base_data := _get_base_data(models)
	
	var config = ConfigFile.new()
	for section in base_data:
		for k in base_data[section]:
			config.set_value(section, k, base_data[section][k])
	if len(key) != 0:
		config.save_encrypted(path, key)
	elif password:
		config.save_encrypted_pass(path, password)
	else:
		config.save(path)
	
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
			if o.type == Variant.Type.TYPE_OBJECT and model[o.name] is FrameworkBindableProperty:
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
