extends RayCast3D
class_name InteractRay

@onready var prompt = $Control/Prompt
@onready var cursor_icon = $Control/CursorIcon

var icons = { 
  "speak": preload("res://mechanics/interact/speak-icon.png") 
}

func _physics_process(delta: float) -> void:
  prompt.text = ""
  cursor_icon.texture = null
  
  if is_colliding():
    var collider = get_collider()
    
    if collider is Interactable:
      _set_icon_by_name(collider.icon_name)
      prompt.text = collider.prompt
      
      if Input.is_action_just_pressed("interact"):
        collider.interact(owner)
      
func _set_icon_by_name(name: String):
  if name in icons.keys():
    cursor_icon.texture = icons[name]
  else:
    cursor_icon.texture = null
      
