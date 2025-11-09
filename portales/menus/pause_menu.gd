extends CanvasLayer

@onready var continue_button: Button = %ContinueButton
@onready var retry_button: Button = %RetryButton
@onready var main_menu_button: Button = %MainMenuButton
@export var pause_menu: CanvasLayer
@onready var quit_button: Button = %QuitButton

func _ready() -> void:
	continue_button.pressed.connect(_on_continue_pressed)
	retry_button.pressed.connect(_on_retry_pressed)
	quit_button.pressed.connect(func(): get_tree().quit())
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		get_tree().paused = not get_tree().paused
		visible = get_tree().paused	
	
func _on_continue_pressed(): 
	visible = false
	get_tree().paused = false

func _on_retry_pressed():
	visible = false
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_main_menu_pressed():
	visible = false
	get_tree().paused = false
	LevelManager.go_to_main_menu()
