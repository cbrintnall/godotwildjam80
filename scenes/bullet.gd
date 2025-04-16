extends Node3D

@onready var cast := $ShapeCast3D as ShapeCast3D

var damage := 1
var shooter: Node
var speed = 4.0
var direction: Vector3

func _ready() -> void:
  cast.target_position = direction

func _physics_process(delta: float) -> void:
  if cast.is_colliding():
    for i in cast.get_collision_count():
      var collider = cast.get_collider(i)
      if collider.has_method("on_take_damage"):
        collider.on_take_damage({
          "amount": damage,
          "owner": shooter
        })
    queue_free()
    
  
  global_position += direction*speed
