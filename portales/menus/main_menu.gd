extends Control

# --- NOTE ---
# This script assumes your buttons are named:
# "Start"
# "Credits"
# "Quit"
#
# If your button nodes have different names,
# you must connect their signals to these functions manually.


## Called when the "Start" button is pressed.
func _on_start_button_pressed():
	print("Start")
	# Calls the global LevelManager to load the first level in its list.
	LevelManager.go_next_level()


## Called when the "Credits" button is pressed.
func _on_credits_button_pressed():
	# Changes the current scene to the credits scene.
	print("Credits")
	get_tree().change_scene_to_file("res://menus/credits.tscn")


## Called when the "Quit" button is pressed.
func _on_quit_button_pressed():
	print("Quit")
	# Closes the game application.
	get_tree().quit()
