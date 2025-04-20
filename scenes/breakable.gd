extends StaticBody3D

@export var health: Health
@export var table: LootTableRef
@export var break_sound: AudioStream
@export var break_particles: PackedScene

func _ready() -> void:
  health.died.connect(_on_die)

func on_take_damage(data:Dictionary):
  health.modify(data)
  
func _on_die():
  if break_sound:
    AudioManager.playd({
      "stream": break_sound,
      "location": global_position,
      "pitch_variance": 0.1,
    })
    
  if break_particles:
    var particles = break_particles.instantiate()
    get_tree().root.add_child(particles)
    particles.global_position = global_position
    particles.emitting = true
    particles.finished.connect(queue_free)

  var item = preload("res://scenes/maps/universal/scenes/loot_item.tscn").instantiate()
  item.global_position = global_position + (global_position.direction_to(Find.player.global_position))
  item.item = table.get_next()
  item.count = 1
  get_tree().root.add_child(item)
  
  queue_free()
