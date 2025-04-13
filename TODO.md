* [ ] 抽象框架中控制反转逻辑 Container

	* [ ] 强制控制每层可获取的对象

* [ ] 事件数据类型化 (name, data) => (Event.new(data))

* [ ] 模型分为完整的和仅（视图层）查询 Readonly field, edit func

* [ ] 命令调整 具备幂等性

* [ ] 模型属性变化多次触发合并为一个

* [ ] 按功能拆分为IStorage, INetwork等细分接口，通过工具层实现具体类

* [ ] 异步资源加载器

* [ ] 模组化 一个模组有多个model和command，model和command整合在一起？