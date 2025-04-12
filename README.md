## 概述

Godot-Framework 提供了简单、强大、易上手、事件驱动、数据驱动的架构。

## 特点

* MVC

* 数据驱动

* 事件系统

* 路由系统

* 音频系统

* 日志系统

* 存档系统

## 框架使用规范

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

  * **工具层**：IUtility，负责提供基础设施，如：存储工具、序列化工具、网络连接工具、蓝牙工具、SDK、对接第三方库等。

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

具体请看示例代码 **/example/..**

## 故障排除

### 无法获取到Framework

* 请确保已启用插件。
