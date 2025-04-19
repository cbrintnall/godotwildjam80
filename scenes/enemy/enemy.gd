extends CharacterBody3D

@onready var nav_agent = $NavigationAgent3D
@onready var health = $Health
@export var animator: AnimationPlayer

var SPEED = 3.0

func _ready() -> void:
  health.died.connect(queue_free)
  add_to_group("enemy")

func _physics_process(delta: float) -> void:
  var current_location = global_transform.origin
  var next_location = nav_agent.get_next_path_position()
  var new_velocity = (next_location - current_location).normalized() * SPEED
  
  nav_agent.set_velocity(new_velocity)
  look_at(next_location)
  start_run_animation()
  
func on_take_damage(data: Dictionary):
  var final_data = health.modify(data)
  
  var pt = data.get("point")
  if pt:
    var text = preload("res://scenes/ui/floating_text.gd").new()
    get_tree().root.add_child(text)
    text.global_position = pt
    text.text = "%d" % final_data["final"]
    if data.get("crit",false):
      text.modulate = Color.YELLOW
      AudioManager.playd({
        "stream": preload("res://audio/hit-crit.ogg")
      })

func update_target_location(target_location):
  nav_agent.target_position = target_location

  
func _on_navigation_agent_3d_target_reached():
  print("in range")

func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
  velocity = velocity.move_toward(safe_velocity, .25)
  move_and_slide()

func start_run_animation():
  if animator and animator.current_animation != "run":
    animator.play("run")
