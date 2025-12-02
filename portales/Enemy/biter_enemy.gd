extends CharacterBody2D

# --- Variables ---
@export var speed: float = 40.0
@export var gravity: float = 500.0

# --- A_I. Variables ---
@export var chase_speed_multiplier: float = 1.5

# State Machine
enum State { PATROL, CHASE, ATTACK }
var current_state: State = State.PATROL

# Scene References
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_timer: Timer = $AttackTimer
@onready var hurtbox: Area2D = $Hurtbox
@onready var player_detection: Area2D = $PlayerDetection
@onready var wall_detector: RayCast2D = $WallDetector
@onready var ledge_detector: RayCast2D = $LedgeDetector
@onready var attack_range: Area2D = $AttackRange
@onready var attack_range_shape: CollisionShape2D = $AttackRange/CollisionShape2D

# Private Variables
var direction: int = 1
var player: CharacterBody2D = null

# --- Audio ---
@onready var sfx_bite: AudioStreamPlayer2D = AudioStreamPlayer2D.new()
const BITE_SOUND = preload("res://musica/SFX[1]/SFX/Chomp.wav")

# --- Godot Functions ---

func _ready() -> void:
	add_to_group("enemy")
	
	# Keep the attack range enabled for detection
	attack_range_shape.disabled = false
	
	sfx_bite.stream = BITE_SOUND
	add_child(sfx_bite)
	
	# Set initial direction based on how you placed it in the editor
	if animated_sprite.flip_h:
		direction = -1
		# Flip all the detectors to match the direction
		wall_detector.target_position.x *= -1
		ledge_detector.position.x *= -1
		attack_range_shape.position.x *= -1
	else:
		direction = 1

func _physics_process(delta: float) -> void:
	# --- 1. Apply Gravity ---
	if not is_on_floor():
		velocity.y += gravity * delta

	# --- 2. Run State Logic ---
	match current_state:
		State.PATROL:
			_patrol_state(delta)
		State.CHASE:
			_chase_state(delta)
		State.ATTACK:
			_attack_state(delta)

	# --- 3. Apply Movement and Animations ---
	move_and_slide()
	_update_animation()

# --- State Logic ---

func _patrol_state(delta: float) -> void:
	# Check for walls or ledges before moving
	if is_on_floor():
		if (wall_detector.is_colliding() or not ledge_detector.is_colliding()) and velocity.x != 0:
			_turn_around()
	
	# Apply horizontal movement
	velocity.x = direction * speed

func _chase_state(delta: float) -> void:
	if not is_instance_valid(player):
		current_state = State.PATROL
		player = null
		return
	
	# Get direction to the player
	var player_dir_x: int = sign(player.global_position.x - global_position.x)
	
	if player_dir_x != 0 and player_dir_x != direction:
		_turn_around()
		
	# Apply faster horizontal movement
	velocity.x = direction * speed * chase_speed_multiplier
	
	# Check if we're in attack range (this will work now)
	if attack_range.has_overlapping_bodies():
		for body in attack_range.get_overlapping_bodies():
			if body.is_in_group("player"):
				current_state = State.ATTACK
				break

func _attack_state(delta: float) -> void:
	# Stop moving
	velocity.x = 0
	
	# Play bite animation and start cooldown
	if attack_timer.is_stopped():
		animated_sprite.play("bite")
		sfx_bite.play()
		attack_timer.start()
		# --- DAMAGE IS MOVED. We wait for the timer to finish. ---


# --- Helper Functions ---

func _deal_damage() -> void:
	# Check all bodies inside the attack range
	for body in attack_range.get_overlapping_bodies():
		if body.is_in_group("player"):
			print("Player BITTEN!")
			get_tree().reload_current_scene()
			# Break so we only kill one player
			break

func _turn_around() -> void:
	direction *= -1
	animated_sprite.flip_h = direction < 0
	wall_detector.target_position.x *= -1
	ledge_detector.position.x *= -1
	attack_range_shape.position.x *= -1

func _update_animation() -> void:
	# Don't change animation if attacking
	if current_state == State.ATTACK:
		return
		
	if is_on_floor():
		if abs(velocity.x) > 5.0:
			animated_sprite.play("move")
		else:
			animated_sprite.play("idle")
	else:
		# No jump animation, so just play idle
		animated_sprite.play("idle") 

# --- Signal Connections ---

func _on_player_detection_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = body
		if current_state != State.ATTACK:
			current_state = State.CHASE

func _on_player_detection_body_exited(body:Node2D) -> void:
	if body.is_in_group("player"):
		player = null
		if current_state != State.ATTACK:
			current_state = State.PATROL

func _on_attack_range_body_entered(body: Node2D) -> void:
	# This signal is only for detection, not damage.
	pass

func _on_attack_range_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		if current_state == State.ATTACK:
			current_state = State.CHASE

func _on_attack_timer_timeout() -> void:
	# --- FIX IS HERE ---
	# The timer has finished, so the attack animation is done.
	# NOW we deal damage.
	_deal_damage()
	
	# And now we decide what to do next.
	# Check if player is still in range
	if attack_range.has_overlapping_bodies():
		for body in attack_range.get_overlapping_bodies():
			if body.is_in_group("player"):
				current_state = State.ATTACK # Stay in attack state
				return
	
	# If player is no longer in attack range, check detection range
	if player_detection.has_overlapping_bodies():
		for body in player_detection.get_overlapping_bodies():
			if body.is_in_group("player"):
				current_state = State.CHASE
				return
				
	# If player is gone, go back to patrolling
	current_state = State.PATROL
