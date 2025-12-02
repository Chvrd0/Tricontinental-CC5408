extends Control

@onready var texture_button: TextureButton = $TextureButton


func _ready():
	$AnimationPlayer.play("credits")
	texture_button.pressed.connect(_on_credits_pressed)
	

func _on_credits_pressed(): 
	LevelManager.go_to_main_menu()
