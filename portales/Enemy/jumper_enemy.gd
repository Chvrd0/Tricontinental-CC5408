extends CharacterBody2D

# --- Variables ---
@export var speed: float = 60.0
@export var jump_force: float = 220.0
@export var gravity: float = 500.0

# --- A_I. Variables ---
@export var patrol_jump_delay: float = 1.5
@export var chase_jump_delay: float = 0.8
@export var patrol_range: float = 80.0  # <--- NEW: How far to move (80 pixels)

# State Machine
enum State { PATROL, CHASE }
var current_state: State = State.PATROL

# Scene References
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var jump_timer: Timer = $JumpTimer
@onready var hurtbox: Area2D = $Hurtbox
@onready var player_detection: Area2D = $PlayerDetection
@onready var wall_detector: RayCast2D = $WallDetector
# @onready var ledge_detector: RayCast2D = $LedgeDetector # <-- We don't need this anymore

# Private Variables
var direction: int = 1
var player: CharacterBody2D = null
var start_position: Vector2 # <--- NEW

# --- Godot Functions ---

func _ready() -> void:
	add_to_group("enemy")
	start_position = global_position # <--- NEW: Remember where we started
	jump_timer.wait_time = patrol_jump_delay
	jump_timer.start()

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

	# --- 3. Apply Movement and Animations ---
	move_and_slide()
	_update_animation()

# --- State Logic ---

func _patrol_state(delta: float) -> void:
	var target_x: float
	
	# Decide which point to jump towards
	if direction == 1:
		target_x = start_position.x + patrol_range
	else:
		target_x = start_position.x - patrol_range
		
	# Check if we're at a wall or past our target
	if is_on_floor():
		if (direction == 1 and global_position.x >= target_x) or \
		   (direction == -1 and global_position.x <= target_x) or \
		   wall_detector.is_colliding():
			
			_turn_around()
			
	# Jump if ready
	_jump_if_ready(direction)


func _chase_state(delta: float) -> void:
	if not is_instance_valid(player):
		current_state = State.PATROL
		player = null
		return
	
	# Get direction to the player
	var player_dir_x: int = sign(player.global_position.x - global_position.x)
	
	# If the player direction is different, update the direction
	if player_dir_x != 0 and player_dir_x != direction:
		_turn_around()
		
	# Jump (will be faster)
	_jump_if_ready(direction)

# --- Helper Functions ---

func _turn_around() -> void:
	direction *= -1
	animated_sprite.flip_h = direction < 0
	wall_detector.target_position.x *= -1
	# ledge_detector.position.x *= -1 # <-- We don't need this anymore
	velocity.x = 0

func _jump_if_ready(horizontal_direction: int) -> void:
	# This function now handles vertical AND horizontal movement
	if is_on_floor() and jump_timer.is_stopped():
		velocity.y = -jump_force
		velocity.x = horizontal_direction * speed
		jump_timer.start() # Restart the one-shot timer

func _update_animation() -> void:
	if not is_on_floor():
		animated_sprite.play("jump")
	else:
		if abs(velocity.x) > 5.0:
			animated_sprite.play("move")
		else:
			animated_sprite.play("idle") 

# --- Signal Connections ---
# (These are unchanged)

func _on_hurtbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("Player hit by Jumper!")
		get_tree().reload_current_scene()

func _on_player_detection_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = body
		current_state = State.CHASE
		jump_timer.wait_time = chase_jump_delay
		if jump_timer.is_stopped():
			jump_timer.start()

func _on_player_detection_body_exited(body:Node2D) -> void:
	if body.is_in_group("player"):
		player = null
		current_state = State.PATROL
		jump_timer.wait_time = patrol_jump_delay
		if jump_timer.is_stopped():
			jump_timer.start()
