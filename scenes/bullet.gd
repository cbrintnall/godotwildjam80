extends Node3D
class_name DefaultBullet

@onready var cast := $ShapeCast3D as ShapeCast3D

var damage := 1
var shooter: Node
var speed = 4.0
var direction: Vector3
var crit_chance := 0.0

func _ready() -> void:
  cast.target_position = direction

func _physics_process(delta: float) -> void:
  if cast.is_colliding():
    for i in cast.get_collision_count():
      var collider = cast.get_collider(i)
      if collider.has_method("on_take_damage"):
        var is_crit = crit_chance >= randf()
        
        collider.on_take_damage({
          "amount": damage,
          "crit": is_crit,
          "owner": shooter,
          "point": cast.get_collision_point(i)
        })
        
        if shooter == Find.player:
          AudioManager.playd({
            "stream": preload("res://audio/hit-confirmation.ogg"),
            "pitch_variance": 0.1
          })
    queue_free()
    
  cast.target_position = -(direction * speed)
  global_position += direction * speed
