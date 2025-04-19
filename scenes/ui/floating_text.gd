extends Label3D

func _ready():
  billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
  font_size = 64
  font = preload("res://fonts/Gothica-Bold.ttf")
  
  await get_tree().process_frame
  
  var t = create_tween()
  t.tween_property(self, "global_position", global_position + Utilities.random_unit_circle_3d() + Vector3.UP * 2.0, 0.3).set_trans(Tween.TRANS_CUBIC)
  t.parallel().tween_property(self, "font_size", 128, 0.1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
  t.chain().tween_property(self, "modulate", Color.TRANSPARENT, 0.5)
  t.tween_callback(queue_free)
