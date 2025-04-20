extends Node
class_name Inventory

@export var inventory_slots_count: int = 16

@export var inventory_grid: GridContainer
@export var inventory_slot_prefab: PackedScene = preload("res://mechanics/inventory/inventory_slot.tscn")

var inventory_slots: Array[InventorySlot] = []

func _ready() -> void:
    self.visible = false # leaving it visible in editor but hide when game  starts
    
    for i in inventory_slots_count:
        var slot = inventory_slot_prefab.instantiate() as InventorySlot
        inventory_grid.add_child(slot)
        slot.slot_id = i
        inventory_slots.append(slot)
        
func _process(_delta: float) -> void:
  if Input.is_action_just_pressed("inventory"):
    self.visible = !self.visible
    self.mouse_filter = Control.MOUSE_FILTER_PASS if self.mouse_filter == Control.MOUSE_FILTER_STOP else Control.MOUSE_FILTER_STOP
    Input.mouse_mode = Input.MOUSE_MODE_CONFINED if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED else Input.MOUSE_MODE_CAPTURED

func add_item(item: ItemRef):
  for slot in inventory_slots:
    if !slot.is_slot_filled():
        slot.fill_slot(item)
        break
