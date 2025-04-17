extends Node
class_name Utilities

static func random_unit_sphere() -> Vector3:
  return Vector3(randf(),randf(),randf()).normalized()
  
static func random_unit_circle_3d() -> Vector3:
  return Vector3(randf(), 0.0, randf()).normalized()
  
static func random_unit_circle() -> Vector2:
  return Vector2(randf(), randf()).normalized()
