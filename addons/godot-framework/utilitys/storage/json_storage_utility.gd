## json格式归档文件
class_name JsonStorageUtility extends IStorageUtility

func _init() -> void:
 datas.push_back({})

func set_data(key: String, value):
 datas[0][key] = value

func save(path: String, secret_key: String = ""):
 var _parsed_path = parse_path(path)
 var dir = _parsed_path[0]
 var file_name = _parsed_path[1]
 if !file_name:
  push_error("Save archive path error.")
  return
 
 var err = DirAccess.make_dir_recursive_absolute(dir)
 if err:
  push_error(err)
  return
 var file = FileAccess.open(path, FileAccess.ModeFlags.WRITE)
 if !file:
  push_error(FileAccess.get_open_error())
  return

 var str := JSON.stringify(datas[0])
 file.store_string(str)
 file.close()

func load(path: String, secret_key: String = ""):
 var file := FileAccess.open(path, FileAccess.ModeFlags.READ)
 if not file:
  push_error(FileAccess.get_open_error())
  return

 var json := JSON.new()
 var error := json.parse(file.get_as_text())
 if error != OK:
  file.close()
  push_error(error)
  return
 var data_received = json.data
 datas[0] = data_received
 file.close()
