extends Resource
class_name LootTableRef

@export var items: Array[ItemRef]
@export var weights: Array[int]

func get_next() -> ItemRef:
  assert(len(items) == len(weights), "Items and weight array should be of same length.")
  return items[RandomNumberGenerator.new().rand_weighted(weights)]
