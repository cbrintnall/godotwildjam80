extends DefaultBullet

@onready var detector := $Area3D
@onready var trail := $Trail3D

var target: Node3D = null

func _ready() -> void:
  super._ready()
  
  speed = 0.1
  detector.body_entered.connect(_on_detect_body)
  
func _on_detect_body(body):
  if target == null and body.is_in_group("enemy"):
    target = body
    
func _process(delta: float) -> void:
  var speed_target = 0.1 if target == null else 1.0
  
  trail.length_limit = 2.0 if target == null else 10.0
  speed = move_toward(speed,speed_target,0.1)
  
  %Visual.look_at(global_position + direction)
  
  if target != null:
    direction = direction.slerp(global_position.direction_to(target.global_position), 0.1)
