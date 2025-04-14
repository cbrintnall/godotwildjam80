extends Weapon
class_name TestPistol

@onready var animator = $"test-pistol/AnimationPlayer"

func start_use():
  super.start_use()
  
  animator.stop()
  animator.play("TestPistol_Shoot")
  
  var audio = StreamData.new()
  audio.stream = preload("res://audio/pistol-shoot.ogg")
  audio.pitch_variance = 0.1
  audio.parent = self
  AudioManager.play(audio)
