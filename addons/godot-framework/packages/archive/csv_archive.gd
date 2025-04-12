## csv格式归档文件
class_name CSVArchive extends Archive

func _init() -> void:
 pass

func add_data(value):
 datas.push_back(value)

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

 if len(datas) < 1:
  return
 var keys := []
 for k in datas[0]:
  keys.push_back(k)
 if not file.store_csv_line(PackedStringArray(keys)):
  file.close()
  push_error("Store csv line error.")
  return
 for data in datas:
  var values := []
  for k in keys:
   values.push_back(data[k])
  if not file.store_csv_line(PackedStringArray(values)):
   file.close()
   push_error("Store csv line error.")
   return
 file.close()

func load(path: String, secret_key: String = ""):
 var file := FileAccess.open(path, FileAccess.ModeFlags.READ)
 if not file:
  push_error(FileAccess.get_open_error())
  return

 var keys := []
 var values: Array[Dictionary] = []
 var is_end = false
 while not is_end:
  var data = file.get_csv_line()
  is_end = !data[0]
  if len(keys) == 0:
   keys = data
  elif not is_end:
   var obj = {}
   for i in range(len(keys)):
    obj.set(keys[i], data[i])
   values.push_back(obj)
 datas = values
 file.close()
