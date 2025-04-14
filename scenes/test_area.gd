extends Node3D

@onready var player = $Player

func _physics_process(_delta: float) -> void:
  get_tree().call_group("Enemies", "update_target_location", player.global_transform.origin)
  
