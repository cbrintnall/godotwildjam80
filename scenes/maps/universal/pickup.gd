extends Node3D

@export var interactable: Interactable

@export_category("data")
@export var item: ItemRef

@export_category("fx")
@export var grab_particles: PackedScene
@export var grab_sound: AudioStream

func _ready():
  interactable.interacted.connect(_on_interact)
  interactable.prompt = "PICKUP"

func _on_interact(_body):
  AudioManager.playd({
    "stream": grab_sound,
    "location": global_position,
    "pitch_variance": 0.15
  })
  
  if grab_particles:
    var particles = grab_particles.instantiate() as GPUParticles3D
    get_tree().root.add_child(particles)
    particles.global_position = global_position
    particles.emitting = true
    particles.finished.connect(particles.queue_free)
  
  Find.player.inventory.add_item(item)
  queue_free()
