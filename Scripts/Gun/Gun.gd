extends Node2D



func _on_Cooddown_timeout() -> void:
	get_parent().get_parent().bullets_shot = 0;
