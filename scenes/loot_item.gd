extends Node3D

@onready var area = $Area3D
@onready var visuals = $loot_bag

var item: ItemRef
var count := 1

var _entered_at := 0.0
var _target: Node3D

func _ready() -> void:
  area.body_entered.connect(_on_entered)
  
func _on_entered(body):
  if _target != null:
    return
    
  _target = body

func _process(delta: float) -> void:
  if _target == null:
    return
    
  _entered_at += delta
  global_position = global_position.move_toward(_target.global_position, _entered_at)
  visuals.rotate(global_position.direction_to(_target.global_position), _entered_at)
  if global_position.distance_to(_target.global_position) < 2.0:
    for i in range(count):
      Find.player.inventory.add_item(item)
    queue_free()
