extends Node
class_name Utilities

static func random_unit_sphere() -> Vector3:
  return Vector3(randf(),randf(),randf()).normalized()
  
static func random_unit_circle_3d() -> Vector3:
  return Vector3(randf(), 0.0, randf()).normalized()
  
static func random_unit_circle() -> Vector2:
  return Vector2(randf(), randf()).normalized()

static func find_node(root: Node, name: String) -> Node:
  if root.name == name:
    return root
    
  for child in root.get_children():
    if child.name == name:
      return child
    else:
      find_node(child, name)
  
  return null
