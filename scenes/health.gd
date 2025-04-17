extends Node
class_name Health

signal died
signal damaged(amt)

@export var max_health := 10

var current_health: int

func _ready() -> void:
  current_health = max_health
  
func modify(data: Dictionary):
  if current_health < 0:
    return
    
  var amount = data["amount"]
  
  if data.get("crit", false):
    amount *= 2.0
  
  current_health -= amount
  
  if sign(amount) >= 0:
    damaged.emit(amount)
  
  if current_health <= 0:
    died.emit()
    
  return {
    "final": amount
  }
