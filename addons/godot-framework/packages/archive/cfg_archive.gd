## cfg格式归档文件
class_name CfgArchive extends Archive

func _init() -> void:
 datas.push_back({})

func set_data(section: String, key: String, value):
 datas[0][section][key] = value

func save(path: String, secret_key: String):
 var _parsed_path = parse_path(path)
 var dir = _parsed_path[0]
 var file_name = _parsed_path[1]
 if !file_name:
  push_error("Save archive path error.")
  return

 var config = ConfigFile.new()
 var base_data = datas[0]
 for section in base_data:
  for k in base_data[section]:
   config.set_value(section, k, base_data[section][k])
 var err: Error = OK
 if secret_key:
  err = config.save_encrypted_pass(path, secret_key)
 else:
  err = config.save(path)
 if err != OK:
  push_error(err)

func load(path: String, secret_key: String):
 var base_data := {}
 var config = ConfigFile.new()
 var err: Error
 if secret_key:
  err = config.load_encrypted_pass(path, secret_key)
 else:
  err = config.load(path)
 if err:
  push_error("Load failed.")
  return
 for section in config.get_sections():
  var data := {}
  for k in config.get_section_keys(section):
   data.set(k, config.get_value(section, k))
  base_data.set(section, data)
  
  datas.clear()
  datas.push_back(base_data)
