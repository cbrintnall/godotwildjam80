extends CharacterBody3D
class_name Player

const DASH_TIME_SECONDS = 0.025
const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const MOUSE_SENS = Vector2(.00075,.00075)
const SPRINT_SPEED := 1.5
const CROUCHED_CAMERA_OFFSET := .9
const ACCEL = 1.0
const DECEL = 0.7
const CROUCH_MULT = 0.1

#@onready var point_cast = %DistanceCast
#@onready var crouch_casts = %CrouchCasts.get_children().filter(func(child): return child is RayCast3D)
@onready var camera := %Camera3D
@onready var ui := $PlayerUI
@onready var inventory := $PlayerUI/Inventory as Inventory
@onready var health := $Health as Health
@onready var weapon_manager := $PlayerWeaponManager
#@onready var main_cast := %MainCast

@export var jump_height := 50.0
@export var push_force := 3.0

var input_dir: Vector2
var stats = {
  "crit_chance": 0.1
}

var frozen: bool:
  get:
    return Find.in_room_load

var look_point:
  get:
    if %LookCast.is_colliding():
      return %LookCast.get_collision_point()
    return camera.global_position + %LookCast.target_position
    
var look_object:
  get:
    if %LookCast.is_colliding():
      return %LookCast.get_collider()
    return null

var looking:
  get:
    return -camera.global_basis.z
    
var eye_pos:
  get:
    return camera.global_position
    
#var look_at_obj:
  #get:
    #if point_cast.is_colliding():
      #return point_cast.get_collider()
    #return null

var _fall_time := 0.0
var _base_collider_height := 2.0
var _crouched_collider_height := .99
var _camera_base_position: Vector3
var _crouched := true
var _target_lean_amt := 0.0
var _head_offset := 0.0
var _was_on_floor := false
var _sprint_held := false
var _last_floor_location: Vector3

#region dash
var _in_dash := false
var _dash_velocity := Vector3.ZERO
#endregion

#region cooldownz
var _time_since_dash := 300.0
#endregion

#region velocities
var _lean_vel: float
var _cvel: Vector3
#endregion

#region camera_stuff
var _enable_camera_animation_data := false
#endregion

#region bonez
@onready var _skeleton = $Node3D/Camera3D/Scalar/player/Player_Armature/Skeleton3D
@onready var _camera_bone_idx = _skeleton.find_bone("CameraBone")
#endregion

#region animationz
@onready var _animator = $Node3D/Camera3D/Scalar/player/AnimationPlayer
#endregion

func reset_to_floor():
  velocity = Vector3.ZERO
  global_position = _last_floor_location

func _ready() -> void:
  add_to_group("player")
  Find.player = self
  Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
  _camera_base_position = camera.position
  %HurtRect.modulate = Color.TRANSPARENT
  health.damaged.connect(_on_damaged)
  #for cast in crouch_casts:
    #cast.add_exception(self)

var hurt_tween: Tween
func _on_damaged(amount:int):
  if hurt_tween != null:
    hurt_tween.kill()
  
  hurt_tween = create_tween()
  hurt_tween.tween_property(%HurtRect,"modulate",Color.RED,0.2)
  hurt_tween.tween_interval(0.1)
  hurt_tween.tween_property(%HurtRect,"modulate",Color.TRANSPARENT,1.0)
  
  AudioManager.playd({
    "stream": preload("res://audio/player-hurt.wav"),
    "pitch_variance": 0.2
  })

func _unhandled_input(event: InputEvent) -> void:
  if frozen:
    return
  
  if event is InputEventMouseMotion:
    var add = MOUSE_SENS * event.relative
    rotate(Vector3.UP,-add.x)
    camera.rotate_x(-add.y)
    
  if event.is_action_pressed("sprint") and _time_since_dash > 2.0:
    _time_since_dash = 0.0
    _in_dash = true
    _fall_time = 0.0
    var projected_dir = Plane(Vector3.UP).project(velocity.normalized())
    velocity.y = 0.0
    _dash_velocity = velocity + (projected_dir * 25.0)
    get_tree().create_timer(DASH_TIME_SECONDS).timeout.connect(func(): _in_dash = false)
    camera.punch_fov(200.0)
    AudioManager.playd({
      "stream": preload("res://audio/player-dash.wav"),
      "pitch_variance": 0.1
    })
    #_cvel += projected_dir*5.0

func _process(delta: float) -> void:
  var cbonetrans: Transform3D = _skeleton.get_bone_global_pose(_camera_bone_idx)
  var cbonepos = cbonetrans.origin
  var cbonerot = cbonetrans.basis.get_euler()
  
  _time_since_dash += delta
  
  DebugDraw2D.set_text("camera pos data", cbonepos)
  DebugDraw2D.set_text("camera rot data", cbonerot)
  DebugDraw2D.set_text("velocity", velocity )
  DebugDraw2D.set_text("speed", Plane(Vector3.UP).project(velocity).length() )
  
  input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
  #_sprint_held = Input.is_action_pressed("sprint")
  
  var lean_mult := input_dir.x * 3.0
  #var sprinting = Input.is_action_pressed("sprint")
  _target_lean_amt = lean_mult
  
  if _enable_camera_animation_data:
    camera.rotation_degrees += cbonerot
    $Node3D.position = cbonepos
  var spr = Springs.spring(camera.rotation_degrees.z,_target_lean_amt,_lean_vel,delta*2.0,20.0,10.0)
  
  camera.rotation_degrees.z = spr["position"]
  _lean_vel = spr["velocity"]
  
  var camera_height := _camera_base_position
  
  if not _was_on_floor and is_on_floor() and not frozen:
    AudioManager.playd({
      "stream": preload("res://audio/jump-land.ogg"),
      "parent": self,
      "pitch_variance": 0.1
    })
    _cvel += Vector3.DOWN*3.0
  
  var walking = velocity.length_squared() > 0.0 and is_on_floor()
  %WalkParticles.emitting = walking
  if walking:
    var speed = .01
    #if sprinting and not _crouched:
      #speed *= SPRINT_SPEED*2.0
    var t = Time.get_ticks_msec()
    var prev = _head_bob((t-delta*1000.0)*speed)
    var base = _head_bob(t*speed)
    var height_offset = 0.5
    
    if is_zero_approx(input_dir.y):
      height_offset /= 4.0
    
    camera.v_offset = base*.05
    
    const threshold = -0.99
    if prev > threshold and base < threshold and not frozen:
      AudioManager.playd({
        "stream":preload("res://audio/dirt-footstep01.ogg"),
        "parent": self,
        "pitch_variance": 0.1,
        "volume": 0.4
      })
  else:
    camera.v_offset = move_toward(camera.v_offset, 0.0, 0.003)
  
  if _crouched:
    camera_height = _camera_base_position + Vector3.DOWN * (_crouched_collider_height-CROUCHED_CAMERA_OFFSET)
  
  var cspr = Springs.spring(camera.position, camera_height, _cvel, delta*2.0, 20.0, 4.0)
  camera.position = cspr["position"]
  _cvel = cspr["velocity"]
  _was_on_floor = is_on_floor()

func _head_bob(x:float):
  #return sin(x+sinh(cos(x/2.0))*4.0)
  return sin(x)

func _physics_process(delta: float) -> void:
  if is_on_floor():
    _last_floor_location = global_position
  
  if _in_dash:
    velocity = _dash_velocity
    move_and_slide()
    return
  
  # Add the gravity.
  if not is_on_floor():
    var mult := 1.0
    var buffer := 0.1
    var amt := buffer*jump_height

    _fall_time += _fall_time*(delta*50.0)
    mult += _fall_time*4.0
    
    if Input.is_action_pressed("jump"):
      mult *= 0.8
      
    var next = velocity + (get_gravity()/2.0*delta*3.0)*mult
    if velocity.y > 0.0 and next.y < 0.0:
      _fall_time = 0.0
    velocity = next
    
  var speed := SPEED
  
  if _sprint_held and is_on_floor():
    speed *= SPRINT_SPEED
    
  if Input.is_action_pressed("jump") and is_on_floor():
    var sound = StreamData.new()
    sound.parent = self
    sound.stream = preload("res://audio/jump01.ogg")
    sound.pitch_variance = 0.3
    sound.volume = 0.5
    AudioManager.play(sound)
    velocity.y = jump_height
    _cvel += Vector3.UP*2.0
    _fall_time = 0.0

  if is_on_ceiling():
    velocity.y = -.01

  var decel = DECEL
  var accel = ACCEL
      
  if not is_on_floor():
    accel = 0.3
    decel = 0.05
    if velocity.y < 0.0:
      speed = min(speed + abs(velocity.y)*0.2, SPEED * 2.0)
  
  var direction = camera.global_transform.basis.x * input_dir.x
  direction += camera.global_transform.basis.z * input_dir.y
  var target_speed = speed
  if direction:
    velocity.x = move_toward(velocity.x, direction.x * target_speed, accel)
    velocity.z = move_toward(velocity.z, direction.z * target_speed, accel)
  else:
    velocity.x = move_toward(velocity.x, 0, decel)
    velocity.z = move_toward(velocity.z, 0, decel)
  move_and_slide()
