## 概述

Godot-Framework 提供了简单、强大、易上手、事件驱动、数据驱动、分层、MVC、路由系统的架构。

## 框架使用规范

| 具体请看示例代码 **/example/**


* 四个层级

  * **视图层**：负责接收输入和数据变化的表现。

	* 可以获取System

	* 可以获取Model

	* 可以发送Command

	* 可以监听Event

  * **系统层**：ISystem，负责视图层的公共逻辑，如：成就系统等。

	* 可以获取System

	* 可以获取Model

	* 可以监听Event

	* 可以发送Event

  * **模型层**：IModel，负责状态的定义和增删查改。

	* 可以获取Utility

	* 可以发送Event

  * **工具层**：IUtility，负责提供基础设施，如：存储方法、序列化方法、网络连接方法、蓝牙方法、SDK、对接第三方库等。

* **命令**：ICommand，负责改变视图层的行为逻辑，只能由视图层调用，如：击杀小怪命令。

  * 可以获取System

  * 可以获取Model

  * 可以发送Event

  * 可以发送Command


* 层级规则

  * 视图层更改ISystem、IModel的状态必须用ICommand

  * ISystem、IModel状态发生变更后通知视图层必须用事件或BindableProperty

  * 视图层可以获取ISystem、IModel对象来进行数据查询

  * ICommand不能有状态

  * 上层可以直接获取下层，下层不能获取上层

  * 上层向下层通信用方法调用（特殊情况：视图层只能用ICommand改变状态）

  * 下层向上层通信用事件

* 路由

	* 配置路由名称和路由的场景路径

	* 配置主路由（主场景路径）

	* 使用路由器进行跳转

## 安装

### 复制插件文件

将Godot-Framework文件夹放入项目的addons目录中：

```
res://addons/godot-framework/
```

### 启用插件

1. 在 Godot 编辑器中，转到项目 > 项目设置 > 插件。
2. 在列表中找到Godot-Framework并将其设置为启用。

### 自动加载

1. 启用插件后，需要在一个脚本中配置应用（如：game_manager.gd）
2. 把脚本添加到自动加载
3. 您可以在项目 > 项目设置 > 全局 > 自动加载中确认这一点。

## 用法

### 定义工具层

```
class_name Storage extends Framework.IUtility

func load(path: String) -> Dictionary:
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.ModeFlags.READ)
		var json_content = file.get_as_text()
		return JSON.parse_string(json_content)
	else:
		return {}

func save(path: String, value):
	var file = FileAccess.open(path, FileAccess.ModeFlags.WRITE)
	file.store_string(JSON.stringify(value))

```

### 定义模型层

```
class_name MobModel extends Framework.IModel

var kill_count = Framework.BindableProperty.new(0)

func on_init():
	var storage = self.app.get_utility(Storage) as Storage
	var data = storage.load("./data")
	if data.has("kill_count"):
		kill_count.value = data["kill_count"]

```

**注意**：model中的属性一定需要使用BindableProperty生成，它是处理属性更新的关键。

### 定义系统层

```
class_name AchievementSystem extends Framework.ISystem

var mob_model: MobModel
func on_init():
	mob_model = self.app.get_model(MobModel) as MobModel
	mob_model.kill_count.register(func(kill_count):
		match kill_count:
			3:
				self.app.eventbus.trigger("achievement_kill_count", "达成普通成就，击杀小怪%s只" % kill_count)
			5:
				self.app.eventbus.trigger("achievement_kill_count", "达成白银成就，击杀小怪%s只" % kill_count)
			10:
				self.app.eventbus.trigger("achievement_kill_count", "达成黄金成就，击杀小怪%s只" % kill_count)
	)

```

### 定义命令

```
class_name MobKillCommand extends Framework.ICommand

func on_execute():
	var mob_model = self.app.get_model(MobModel) as MobModel
	mob_model.kill_count.value += 1

```

### 启动框架

这里通过自动加载一个game_manager.gd文件使用。

```
extends Node

var app: Framework.App

func _ready() -> void:
	app = Framework.App.new()
	app.register_system(AchievementSystem)
	app.register_model(MobModel)
	app.register_utility(Storage)
	app.enable_router(get_window())
	app.router.register("one", "res://example/scenes/one.tscn")
	app.router.register("two", "res://example/scenes/two.tscn")
	app.router.set_main_route_name("one")
	app.run()

```

### 具体应用

```
# one.gd

extends Node2D

@onready var kill_label: Label = %KillLabel
@onready var achievement_label: Label = %AchievementLabel
@onready var kill_button: Button = %KillButton
@onready var router: Label = %Router
var mob_model: MobModel

func _ready() -> void:
	# 读取数据
	mob_model = GameManager.app.get_model(MobModel) as MobModel
	mob_model.kill_count.register_with_init_value(func(kill_count):
		kill_label.text = "已击杀 {0} 次".format([kill_count])
	).unregister_when_node_exit_tree(self)
	
	# 监听数据更新
	GameManager.app.eventbus.register("achievement_kill_count", func(value):
		achievement_label.text = value
	).unregister_when_node_exit_tree(self)
	router.text = "存在 {0} 个路由记录\n当前路由: {1}".format([len(GameManager.app.router.history), GameManager.app.router.current_route])

# 视图层触发命令
func _on_kill_button_pressed() -> void:
	GameManager.app.send_command(MobKillCommand.new())

func _on_jump_button_pressed() -> void:
	GameManager.app.router.push("two")

# two.gd

extends Node2D

@onready var kill_label: Label = %KillLabel
@onready var jump_button: Button = %JumpButton
@onready var router: Label = %Router

func _ready() -> void:
	var mob_model = GameManager.app.get_model(MobModel) as MobModel
	mob_model.kill_count.register_with_init_value(func(kill_count):
		kill_label.text = "在上一个场景中，已击杀 {0} 个小怪。".format([kill_count])
	).unregister_when_node_exit_tree(self)
	router.text = "存在 {0} 个路由记录\n当前路由: {1}".format([len(GameManager.app.router.history), GameManager.app.router.current_route])


func _on_jump_button_pressed() -> void:
	# 跳转前一个
	GameManager.app.router.back()
	# 跳转前一个
	#GameManager.app.router.go(-1)
	# 跳转名为one的路由
	#GameManager.app.router.push("one")

```

## 故障排除

### 无法获取到Framework

* 请确保已启用插件。
