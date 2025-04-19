extends Node3D

var active := true

@export var area: Area3D
@export var bounce_sound: AudioStream

func _ready() -> void:
  area.body_entered.connect(_bounce_body)
  
func _bounce_body(body):
  if not active:
    return
  
  if body is CharacterBody3D:
    body.velocity.y += 25.0
    AudioManager.playd({
      "stream": bounce_sound,
      "pitch_variance": 0.1,
      "volume": 1.2,
      "location": global_position
    })
