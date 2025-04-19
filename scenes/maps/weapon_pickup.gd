extends Node3D

@export var interactable:Interactable
@export var weapon: NodePath

func _ready() -> void:
  interactable.interacted.connect(func(body):
    if body == Find.player:
      Find.player.weapon_manager.pickup_weapon(get_node(weapon))
      queue_free()
  )
