extends Interactable

@export var dialogue_timeline_name = ""

func _on_interacted(_body):
  if Dialogic.current_timeline != null:
    return
    
  Dialogic.start(dialogue_timeline_name)
