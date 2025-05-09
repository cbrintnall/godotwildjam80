@tool
extends EditorScenePostImport

func _post_import(scene: Node) -> Object:
  _ensure_level_data(scene)
  _each_node(scene)
  # Modify the contents of the scene upon import.
  return scene # Return the modified root node when you're done.

func _ensure_level_data(scene: Node):
  if not get_source_file().contains("raw"):
    return
  
  var path = "res://scenes/maps/%s" % scene.name
  if not DirAccess.dir_exists_absolute(path):
    var err = DirAccess.make_dir_absolute(path)
  
  var file = "%s/%s.tscn" % [path,scene.name]
  if not FileAccess.file_exists(file):
    var room_scene = PackedScene.new()
    var room = Room.new()
    var level = load(get_source_file()).instantiate()
    room.add_child(level)
    level.owner = room
    room_scene.pack(room)
    ResourceSaver.save(room_scene,file)
    var keys = load("res://data/room_keys.json").data
    keys[scene.name] = file
    var f = FileAccess.open("res://data/room_keys.json", FileAccess.WRITE)
    f.store_string(JSON.stringify(keys))
    print("created scene for non-existent level %s" % file)

func _each_node(node: Node):
  if node == null:
    return
    
  if node.name.contains("-entrance"):
    _handle_entrance(node as MeshInstance3D)
    
  if node.get_class() == "Node3D":
    node.add_to_group(node.name, true)
  
  for child in node.get_children():
    _each_node(child)
    
func _get_entrance_tag(node:MeshInstance3D) -> String:
  var entrance_rg = RegEx.new()
  entrance_rg.compile("-entrance=([^\\s]+)")
  var res = entrance_rg.search(node.name)
  var key = res.get_string(1)
  node.name = node.name.replace(res.get_string(0), "").strip_edges()
  return key
  
func _get_entrance_scene(node:MeshInstance3D) -> String:
  var entrance_rg = RegEx.new()
  entrance_rg.compile("-scene=([^\\s]+)")
  var res = entrance_rg.search(node.name)
  var key = res.get_string(1)
  node.name = node.name.replace(res.get_string(0), "").strip_edges()
  return key

func _handle_entrance(node: MeshInstance3D):
  var scene_map = load("res://data/room_keys.json").data
  var area = RoomEdge.new()
  var collider = CollisionShape3D.new()
  var key = _get_entrance_tag(node)
  var scene = _get_entrance_scene(node)
  var name = node.name

  area.target = key
  area.scene = scene_map[scene]
  area.collision_mask = 2 # player
  area.add_to_group("entrance",true)
  
  collider.shape = node.mesh.create_trimesh_shape()
  collider.debug_color = Color.GREEN_YELLOW
  
  area.add_child(collider)
  
  var parent = node.get_parent()
  var index = node.get_index()

  parent.add_child(area)
  parent.move_child(area, index)
  
  area.owner = node.owner
  collider.owner = node.owner  
  area.transform = node.transform
  
  node.queue_free()
  
  area.name = name
  collider.name = "%s_collider" % name
