extends CanvasLayer

@onready var progress_bar: ProgressBar = %ProgressBar

var _load_router_control: RouterUtility.LoadRouterControl

func _ready() -> void:
	_load_router_control = RouterUtility.LoadRouterControl.new()
	_load_router_control.bind_update_func(
		func (p):
			progress_bar.value = p
	)
	_load_router_control.bind_finished_func(
		func ():
			set_physics_process(false)
			await get_tree().create_timer(0.3).timeout
	)
	await get_tree().create_timer(0.3).timeout
	_load_router_control.load()

func _physics_process(delta: float) -> void:
	_load_router_control.update()
