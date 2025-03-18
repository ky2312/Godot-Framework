extends Node2D

@onready var label: Label = %Label
@onready var button: Button = %Button
@onready var router: Label = %Router

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var mob_model = GameManager.app.get_model(MobModel) as MobModel
	mob_model.kill_count.register_with_init_value(func(kill_count):
		label.text = label.text % kill_count
	).unregister_when_node_exit_tree(self)
	router.text = router.text.format([len(GameManager.app.router.history), GameManager.app.router.current_route])


func _on_button_pressed() -> void:
	# 跳转前一个
	GameManager.app.router.back()
	# 跳转前一个
	#GameManager.app.router.go(-1)
	# 跳转名为one的路由
	#GameManager.app.router.push("one")
