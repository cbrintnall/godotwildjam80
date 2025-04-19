extends Node
class_name Utilities

static func random_unit() -> float:
  return randf_range(-1.0, 1.0)

static func random_unit_sphere() -> Vector3:
  return Vector3(random_unit(),random_unit(),random_unit()).normalized()
  
static func random_unit_circle_3d() -> Vector3:
  return Vector3(random_unit(), 0.0, random_unit()).normalized()
  
static func random_unit_circle() -> Vector2:
  return Vector2(random_unit(), random_unit()).normalized()

static func find_node(root: Node, name: String) -> Node:
  if root.name == name:
    return root
    
  for child in root.get_children():
    if child.name == name:
      return child
    else:
      find_node(child, name)
  
  return null
