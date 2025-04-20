extends Control
class_name InventorySlot

@export var texture_rect: TextureRect
@export var slot_id: int = -1

var slot_data: ItemRef

func is_slot_filled() -> bool:
  return !!slot_data

func fill_slot(item: ItemRef):
  slot_data = item
  texture_rect.texture = slot_data.preview
