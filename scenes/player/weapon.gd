extends Node3D
class_name Weapon

@export var barrel: Marker3D
@export var animator: AnimationPlayer
@export var shoot_sound: AudioStream
@export var max_ammo := 8
@export var damage := 1
@export var crystal_mesh: Node3D

var current_ammo := 0
#var bullet_ref := preload("res://data/bullets/default.tres")
var bullet_ref := preload("res://data/bullets/tracking.tres")

var _last_reload_time: float
var _normalized_ammo: float:
  get:
    return float(current_ammo) / max_ammo

var _animation_progress: float:
  get:
    return animator.current_animation_position / animator.current_animation_length

func _ready():
  current_ammo = max_ammo
  animator.animation_finished.connect(func(anim):
    if anim == "Reload":
      current_ammo = max_ammo
  )
  
func _unhandled_input(event: InputEvent) -> void:
  if event.is_action_pressed("reload"):
    _last_reload_time = Time.get_ticks_msec()

func start_use() -> bool:
  if animator.current_animation == "Reload":
    return false
  
  if current_ammo == 0:
    AudioManager.playd({
      "stream": preload("res://audio/out-of-ammo.ogg"),
      "pitch_variance": 0.2
    })
    animator.stop()
    animator.play("Reload")
    return true
  
  if animator.current_animation == "Shoot":
    return false
  
  animator.stop()
  animator.play("Shoot")
  
  %ShotParticles.amount = _normalized_ammo * 30.0
  %ShotParticles.restart()
  
  Find.player.camera.shake(0.4, 0.2, preload("res://data/curve_shoot_camera_shake.tres"), Vector2.UP)
  AudioManager.playd({
    "stream": shoot_sound,
    "pitch_variance": 0.1,
    "pitch_additional": (1.0 - _normalized_ammo),
    "parent": self
  })
  
  
  var bullet = bullet_ref.scene.instantiate()
  bullet.direction = barrel.global_position.direction_to(Find.player.look_point)
  bullet.global_position = barrel.global_position
  bullet.shooter = Find.player
  bullet.crit_chance = Find.player.stats["crit_chance"]
  bullet.damage = damage
  get_tree().root.add_child(bullet)
  
  if not Find.unlimited_ammo:
    current_ammo -= 1
  
  return true
  
func end_use():
  pass

func _process(delta: float) -> void:
  var reload_buffer = Time.get_ticks_msec() - _last_reload_time
  if reload_buffer < 250.0:
    if current_ammo < max_ammo and animator.current_animation == "Idle":
      animator.stop()
      animator.play("Reload")  
  
  Find.player.ui.ammo_counter.text = "%d / %d" % [ current_ammo, max_ammo ]
  
  # weird origin issues, so commented out
  #%GlowSprite.scale = max(_normalized_ammo,0.01) * Vector3.ONE
  crystal_mesh.scale = %GlowSprite.scale
