extends CollisionObject3D
class_name Interactable

signal interacted(body)

@export var enabled = true
@export var prompt = ""
@export var icon_name = ""

func interact(body):
	if not enabled:
		return
	
	interacted.emit(body)
