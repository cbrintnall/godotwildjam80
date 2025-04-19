extends Node3D
class_name Room

@export var death_plane: Area3D

@onready var spawn = get_tree().get_first_node_in_group("Spawn")

func _ready() -> void:
  if death_plane:
    death_plane.collision_mask = 2
    death_plane.body_entered.connect(func(body):
      if body == Find.player and not Find.in_room_load:
        Find.player.reset_to_floor()
        Find.player.health.modify({
          "amount": 1
        })
    )
  
  if Find.active_room == null:
    Find.active_room = self
  
  # We're likely in debug mode, spawn one at rooms spawn
  if Find.player == null:
    var player = preload("res://scenes/player/player.tscn").instantiate()
    add_child(player)
    player.global_position = spawn.global_position
    player.rotation_degrees = spawn.rotation_degrees
