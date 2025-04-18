extends Node

var weapon

var _time_since_use_pressed := 0.0
var _use_buffered := false
var _gvel: Vector3

func _unhandled_input(event: InputEvent) -> void:
  if event.is_action_pressed("activate"):
    _time_since_use_pressed = Time.get_ticks_msec()
    _use_buffered = true
    
  if event is InputEventMouseMotion and weapon != null:
    weapon.rotation_degrees.y += event.relative.x*.01
    weapon.rotation_degrees.x += event.relative.y*.01

func _process(delta: float) -> void:
  if weapon:
    var res = Springs.spring(weapon.rotation_degrees, Vector3.ZERO, _gvel, delta*2.0, 20.0, 3.0)
    weapon.rotation_degrees = res["position"]
    _gvel = res["velocity"]
  
    if Time.get_ticks_msec() - _time_since_use_pressed < 250.0 and _use_buffered:
      var success = weapon.start_use()
      _use_buffered = not success
