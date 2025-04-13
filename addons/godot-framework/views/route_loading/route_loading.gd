extends CanvasLayer

@onready var progress_bar: ProgressBar = %ProgressBar

var _load_router_control: RouterUtility.LoadRouterControl

func _ready() -> void:
	var update_callback = func(p):
		progress_bar.value = p
	var finished_callback = func():
		set_physics_process(false)
		await get_tree().create_timer(0.3).timeout

	_load_router_control = RouterUtility.LoadRouterControl.new(GameManager.app.router, update_callback, finished_callback)
	await get_tree().create_timer(0.3).timeout
	_load_router_control.load()

func _physics_process(delta: float) -> void:
	_load_router_control.update()
