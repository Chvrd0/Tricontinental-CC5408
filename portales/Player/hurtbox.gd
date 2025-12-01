class_name  Hurtbox
extends Area2D

signal hurt_felt

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	
	
func _on_area_entered(area: Area2D):
	var hitbox = area as Hitbox
	if hitbox: 
		if owner.has_method("destroy"):
			hitbox.damage_dealt.emit()
			owner.destroy()
