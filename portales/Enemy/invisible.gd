class_name InvisibleBarrier
extends CharacterBody2D

# --- Referencias a Nodos ---
# Solo necesitamos el Hurtbox para detectar el choque.
# Asumo que el sprite sigue ahí aunque no se vea, para que tengas referencia en el editor.
@onready var hurtbox: Area2D = $Hurtbox 

func _ready() -> void:
	add_to_group("enemy")
	
	# 1. HACERLO INVISIBLE
	# Al poner 'visible' en false, se oculta el Sprite y todos los hijos visuales.
	# Las colisiones seguirán funcionando.
	visible = false 

func _physics_process(_delta: float) -> void:
	# 2. FLOTAR Y NO MOVERSE
	# Al dejar esta función vacía (o simplemente no poner código de movimiento),
	# el objeto no se ve afectado por la gravedad ni se mueve. 
	# Se queda congelado donde lo pongas en el editor.
	pass

# --- Señal de Colisión (La misma lógica de antes) ---

func _on_hurtbox_body_entered(body: Node2D) -> void:
	# Si el jugador toca el área de daño (Hurtbox), reinicia el nivel.
	if body.is_in_group("player"):
		print("Jugador tocó la barrera invisible. Reiniciando...")
		call_deferred("_reload_scene")

func _reload_scene() -> void:
	get_tree().reload_current_scene()
