extends CanvasLayer

signal fade_phase_finished

@onready var ammo_counter := %AmmoCounter

func _ready() -> void:
  %FadeRect.modulate = Color.TRANSPARENT

func do_fade():
  var t = create_tween()
  t.tween_property(%FadeRect,"modulate",Color.BLACK,2.0)
  t.tween_callback(fade_phase_finished.emit)
  
func do_unfade():
  var t = create_tween()
  t.tween_property(%FadeRect,"modulate",Color.TRANSPARENT,2.0)
  t.tween_callback(fade_phase_finished.emit)
