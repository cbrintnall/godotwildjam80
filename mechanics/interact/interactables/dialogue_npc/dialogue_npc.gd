extends CharacterBody3D

@export var dialogue_timeline_name = ""

func _ready() -> void:
  $Interactable.interacted.connect(_on_interacted)

func _on_interacted(_body):
  if Dialogic.current_timeline != null:
    return
    
  Dialogic.start(dialogue_timeline_name)
