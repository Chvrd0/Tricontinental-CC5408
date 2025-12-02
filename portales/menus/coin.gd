extends Area2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var playback = animation_tree["parameters/playback"]

# --- Audio ---
@onready var sfx_coin: AudioStreamPlayer = AudioStreamPlayer.new()
const COIN_SOUND = preload("res://musica/SFX[1]/SFX/Coin.wav")


var is_collected = false


func _ready() -> void:
	sfx_coin.stream = COIN_SOUND
	add_child(sfx_coin)
	body_entered.connect(_on_body_entered)

	

func _physics_process(delta: float) -> void:
	if is_collected: return
	
	playback.travel("idle_coin")
	
	
func _on_body_entered(body :Node2D):
	var player = body as Player
	if player and not is_collected:
		is_collected = true
		
		# 1. Disable collision immediately
		set_deferred("monitoring", false)
		
		# 2. Play Sound
		sfx_coin.play()
		
		var visual_up = -player.global_transform.y.normalized()
		var tween = create_tween()
		var jump_height: float = 60.0
		var target_global_pos = global_position + (visual_up * jump_height)
		
		var duration = 0.8
		tween.tween_property(self, "global_position", target_global_pos, duration)\
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "rotation", rotation + 4 * PI, duration)
		tween.tween_property(self, "scale", Vector2(1.5, 1.5), duration)
		tween.tween_property(self, "modulate", Color(5, 5, 5, 0), duration)
		await tween.finished
		
		LevelManager.go_next_level()
