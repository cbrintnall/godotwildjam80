extends StaticBody3D

var open := false

func _ready() -> void:
  $trampoline.active = false;
  $AnimationPlayer.stop()
  $puffplant/Timer.stop()
  $GPUParticles3D.emitting = false
  
func on_take_damage(data:Dictionary):
  if open:
    return
    
  if data["amount"] <= 0:
    return
    
  open = true;
  $trampoline.active = true;
  $AnimationPlayer.play("active")
  $puffplant/Timer.start()
  $GPUParticles3D.emitting = true
  $CollisionShape3D.disabled = true
    
  
