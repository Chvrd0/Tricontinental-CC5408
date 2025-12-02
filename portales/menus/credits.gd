extends Control

@onready var texture_button: TextureButton = $TextureButton


func _ready():
	$AnimationPlayer.play("credits")
	texture_button.pressed.connect(_on_credits_pressed)
	

func _on_credits_pressed(): 
	LevelManager.go_to_main_menu()
	

func _process(delta):
	# Check for "Enter" (ui_accept) OR "Escape" (pause)
	if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("pause"):
		_return_to_menu()

# I renamed this function to be more generic since it's used by keys AND mouse now
func _return_to_menu():
	LevelManager.go_to_main_menu()
