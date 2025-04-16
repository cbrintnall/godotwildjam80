extends CharacterBody3D

@onready var nav_agent = $NavigationAgent3D
@onready var health = $Health

var SPEED = 3.0

func _ready() -> void:
  health.died.connect(queue_free)

func _physics_process(delta: float) -> void:
  var current_location = global_transform.origin
  var next_location = nav_agent.get_next_path_position()
  var new_velocity = (next_location - current_location).normalized() * SPEED
  
  nav_agent.set_velocity(new_velocity)
  
func on_take_damage(data: Dictionary):
  health.modify(data["amount"])

func update_target_location(target_location):
  nav_agent.target_position = target_location

  
func _on_navigation_agent_3d_target_reached():
  print("in range")


func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
  velocity = velocity.move_toward(safe_velocity, .25)
  move_and_slide()
