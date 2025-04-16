extends Node3D
class_name Weapon

@export var barrel: Marker3D
@export var animator: AnimationPlayer
@export var shoot_sound: AudioStream
@export var max_ammo := 8

var current_ammo := 0

func _ready():
  current_ammo = max_ammo
  animator.animation_finished.connect(func(anim):
    if anim == "Reload":
      current_ammo = max_ammo
  )

func start_use():
  if current_ammo == 0:
    if animator.current_animation == "Reload":
      return
    animator.stop()
    animator.play("Reload")
    return
  
  if animator.current_animation == "Shoot":
    return
  
  animator.stop()
  animator.play("Shoot")
  
  AudioManager.playd({
    "stream": shoot_sound,
    "pitch_variance": 0.1,
    "parent": self
  })
  
  var bullet = preload("res://scenes/player/weapons/bullet.tscn").instantiate()
  bullet.direction = barrel.global_position.direction_to(Find.player.look_point)
  bullet.global_position = barrel.global_position
  get_tree().root.add_child(bullet)
  
  current_ammo -= 1
  
  await animator.animation_finished
  
  animator.play("Idle")
  
func end_use():
  pass

func _process(delta: float) -> void:
  Find.player.ui.ammo_counter.text = "%d / %d" % [ current_ammo, max_ammo ]
