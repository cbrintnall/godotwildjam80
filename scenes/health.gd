extends Node
class_name Health

signal died
signal damaged

@export var max_health := 10

var current_health: int

func _ready() -> void:
  current_health = max_health
  
func modify(amount: int):
  if current_health < 0:
    return
    
  current_health -= amount
  
  if sign(amount) >= 0:
    damaged.emit()
  
  if current_health <= 0:
    died.emit()
