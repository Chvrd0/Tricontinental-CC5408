extends Area2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var playback = animation_tree["parameters/playback"]

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	
func _on_body_entered(body :Node2D):
	var player = body as Player
	if player:
		LevelManager.go_next_level()
		
func _physics_process(delta: float) -> void:
	playback.travel("idle_coin")
