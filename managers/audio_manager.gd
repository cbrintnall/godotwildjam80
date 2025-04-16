extends Node

var _players := []

func _ready():
  const start = 5
  for i in start:
    _players.push_back(AudioStreamPlayer3D.new())
    add_child(_players[-1])
    
func playd(data: Dictionary):
  var stream_data = StreamData.new()
  stream_data.stream = data["stream"]
  stream_data.pitch_variance = data.get("pitch_variance", 0.0)
  stream_data.parent = data.get("parent")
  stream_data.location = data.get("location")
  play(stream_data)
    
func play(data: StreamData):
  var player : AudioStreamPlayer3D
  if len(_players) > 0:
    player = _players.pop_back()
  else:
    _players.push_back(AudioStreamPlayer3D.new())
    add_child(_players[-1])
    player = _players.pop_back()
    
  player.stream = data.stream
  player.pitch_scale = 1.0 + (randf()*data.pitch_variance)
  
  if data.parent:
    player.reparent(data.parent, false)
  elif data.location != Vector3.ZERO:
    player.global_position = data.location
    
  player.play()
  player.finished.connect(_players.push_back.bind(player), CONNECT_ONE_SHOT)
