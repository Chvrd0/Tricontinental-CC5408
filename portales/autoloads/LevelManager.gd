extends Node

# --- Scenes ---
# We export this array so you can drag-and-drop [Tutorial.tscn, Level2.tscn] in the Inspector.
@export var levels: Array[PackedScene] 
@export var main_menu: PackedScene
@export var credits: PackedScene

# --- Music Assets ---
# Song 1: Main Menu
const MUSIC_MENU = preload("res://musica/Spining_Cat.mp3")
# Song 2: Tutorial (Index 0)
const MUSIC_TUTORIAL = preload("res://musica/イッツ・ア・ヘンテコワールド.mp3") 
# Song 3: Level 2 (Index 1)
const MUSIC_LEVEL2 = preload("res://musica/ピコピコ・リパブリック賛歌_-_8bit.mp3")

# --- Internal Variables ---
var current_level = -1
var music_player: AudioStreamPlayer

func play_music(stream: AudioStream):
	# If the requested song is already playing, don't restart it
	if music_player.stream == stream and music_player.playing:
		return 
	
	music_player.stream = stream
	music_player.play()


func _ready():
	# Create a persistent audio player that survives scene changes
	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	music_player.volume_db = -10.0 # Adjust volume as needed
	
	# Optional: If you run the game starting from the Main Menu scene, 
	# you might want to call play_music(MUSIC_MENU) here or in the menu's _ready.
	if current_level == -1:
		play_music(MUSIC_MENU)


func go_next_level():
	current_level += 1
	print("Loading level index: ", current_level)
	
	if current_level < levels.size():
		# Change the scene
		get_tree().change_scene_to_packed(levels[current_level])
		
		# --- Play Music based on the Array Index ---
		if current_level == 0:
			# Array [0] is your Tutorial
			play_music(MUSIC_TUTORIAL)
		elif current_level == 1:
			# Array [1] is Level 2
			play_music(MUSIC_LEVEL2)
	else:
		go_to_credits()

func go_to_main_menu():
	if main_menu:
		get_tree().change_scene_to_packed(main_menu)
		current_level = -1
		play_music(MUSIC_MENU) # Song 1

func go_to_credits():
	if credits:
		get_tree().change_scene_to_packed(credits)
		
		play_music(MUSIC_MENU)

func _dead(pause_menu : CanvasLayer):
	pause_menu.visible = not pause_menu.visible
