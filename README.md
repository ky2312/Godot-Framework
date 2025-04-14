## 概述

Godot-Framework 提供了简单、强大、易上手、事件驱动、数据驱动的架构。

## 框架使用规范

<!-- * 视图层
  * 依赖 应用层、基础设施层（监听数据变更）
* 应用编排层
  * 依赖 领域层
* 领域服务层
  * 不依赖
* 基础设施层
  * 依赖（控制反转） 应用层、领域层 -->

* 四个层级

  * **视图层**：负责接收输入和数据变化的表现。

    * 可以获取IModel进行数据查询

    * 可以发送ICommand

    * 可以监听事件

  * **系统层**：ISystem，负责业务逻辑，如：成就系统等。

    * 可以获取IModel进行数据查询和修改

    * 可以获取IUtility进行方法调用

    * 可以监听事件

    * 可以发送事件

  * **模型层**：IModel，负责状态的定义和增删查改，必须使用BindableProperty。

    * 可以对属性变化发送事件（由BindableProperty实现）
    
    * 可以发送事件

  * **工具层**：IUtility，负责提供基础设施（业务无关），如：存储、序列化、网络连接、蓝牙、SDK、对接第三方库等。

    * 可以获取IUtility进行方法调用

* **命令**：ICommand，负责改变视图层的行为逻辑，只能由视图层调用，如：击杀小怪命令。

  * 可以获取ISystem进行方法调用

  * 可以获取IModel进行数据查询和修改

* 层级规则

  * 视图层只能通过在命令中调用系统层方法改变模型层状态

  * 系统层动作完成后可以进行事件通知

  * 模型层的成员属性变更后会进行事件通知

  * 命令不能有状态

  * 命令是行为发生时调用

  * 事件是行为发生后调用

  * 上层可以直接获取下层，下层不能获取上层

  * 上层向下层通信用方法调用
  
    * 特殊情况：视图层只能用命令改变状态

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
