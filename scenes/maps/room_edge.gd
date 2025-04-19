extends Area3D
class_name RoomEdge

@export var scene: String
@export var target: String

func _ready():
  body_entered.connect(_on_player_entered)
  
func _on_player_entered(body):
  if body != Find.player:
    return
    
  if Find.in_room_load:
    push_error("room was loading, but attempted to load another")
    return
    
  print("starting room load..")
    
  Find.player.ui.do_fade()
  Find.in_room_load = true
  await Find.player.ui.fade_phase_finished
    
  var room = load(scene).instantiate()
  var tree = get_tree()
  get_tree().root.add_child(room)
  await get_tree().process_frame
  room.position = Vector3.ZERO
  var target_point = get_tree().get_first_node_in_group(target)
  if target_point:
    body.global_position = target_point.global_position
    body.rotation_degrees = target_point.rotation_degrees
    body.reparent(room)
    Find.active_room.queue_free()
    Find.active_room = room
    
    # add some delay so it isn't jarring, this node is freed so NO AWAIT
    tree.create_timer(0.5).timeout.connect(func():
      Find.player.ui.do_unfade()
      Find.in_room_load = false
    )
  else:
    room.queue_free()
    Find.player.ui.do_unfade()
    Find.in_room_load = false
    push_error("room load failed, scene=%s target=%s" % [ scene, target ])
  
