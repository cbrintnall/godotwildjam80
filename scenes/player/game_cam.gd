extends Camera3D
class_name GameCam

var data := {}
var elapsed := 0.0

func shake(time: float, intensity: float, curve: Curve, direction := Vector2.ZERO):
  data["time"] = time
  data["intensity"] = intensity
  data["curve"] = curve
  data["direction"] = Utilities.random_unit_circle() if direction == Vector2.ZERO else direction
  
  elapsed = 0.0
  
func _process(delta: float) -> void:
  if data != {} and elapsed < data["time"]:
    var normalized = clampf(elapsed/data["time"], 0.0, 1.0)
    var offset = data["curve"].sample(normalized) * data["intensity"] * data["direction"]
    
    h_offset = offset.x
    v_offset = offset.y
    
  elapsed += delta
