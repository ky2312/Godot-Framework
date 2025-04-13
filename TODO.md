* [x] 抽象框架中控制反转逻辑 Container

	* [x] 强制控制每层可获取的对象

* [x] 新的事件总线依赖逻辑

* [x] 命令调整

<!-- * [ ] 模型分为完整的和仅（视图层）查询 Readonly field, edit func -->

<!-- * [ ] 事件数据类型化 (name, data) => (Event.new(data)) -->

<!-- * [ ] 模型属性变化多次触发合并为一个 -->

* [x] 按功能拆分为IStorage, INetwork等细分接口，通过工具层实现具体类

* [x] 整合各个层级入参上下文

* [x] 异步资源加载器

* [ ] 模组化 一个模组有多个model和command，model和command整合在一起？