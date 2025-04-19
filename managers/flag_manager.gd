extends Node

var flags := {}

func set_flag(name: String, amount := 1):
  if not flags.has(name):
    flags[name] = 0
    
  flags[name] += amount
  
func flag_unlocked(name: String) -> bool:
  return flag_set(name, 1)
  
func flag_set(name: String, amount: int):
  return flags.get(name, 0) >= amount
