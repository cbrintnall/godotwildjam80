extends CharacterBody3D
class_name Player

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
#@onready var main_cast := %MainCast

@export var jump_height := 50.0
@export var push_force := 3.0

var input_dir: Vector2

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
var _lean_vel: float
var _cvel: Vector3
var _head_offset := 0.0
var _was_on_floor := false
var _sprint_held := false

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

func _ready() -> void:
  add_to_group("player")
  Find.player = self
  Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
  _camera_base_position = camera.position
  #for cast in crouch_casts:
    #cast.add_exception(self)

func _unhandled_input(event: InputEvent) -> void:
  if event is InputEventMouseMotion:
    var add = MOUSE_SENS * event.relative
    rotate(Vector3.UP,-add.x)
    camera.rotate_x(-add.y)
    
  if event.is_action_pressed("activate"):
    var wep = $Node3D/Camera3D/Scalar/revolver
    wep.start_use()

func _process(delta: float) -> void:
  var cbonetrans: Transform3D = _skeleton.get_bone_global_pose(_camera_bone_idx)
  var cbonepos = cbonetrans.origin
  var cbonerot = cbonetrans.basis.get_euler()
  
  DebugDraw2D.set_text("camera pos data", cbonepos)
  DebugDraw2D.set_text("camera rot data", cbonerot)
  
  input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
  _sprint_held = Input.is_action_pressed("sprint")
  
  var lean_mult := input_dir.x * 3.0
  var sprinting = Input.is_action_pressed("sprint")
  _target_lean_amt = lean_mult
  
  if _enable_camera_animation_data:
    camera.rotation_degrees += cbonerot
    $Node3D.position = cbonepos
  var spr = Springs.spring(camera.rotation_degrees.z,_target_lean_amt,_lean_vel,delta*2.0,20.0,10.0)
  
  camera.rotation_degrees.z = spr["position"]
  _lean_vel = spr["velocity"]
  
  var camera_height := _camera_base_position
  
  if not _was_on_floor and is_on_floor():
    var sound = StreamData.new()
    sound.parent = self
    sound.stream = preload("res://audio/dirt-footstep01.ogg")
    sound.pitch_variance = 0.1
    AudioManager.play(sound)
    _cvel += Vector3.DOWN*3.0
  
  if velocity.length_squared() > 0.0 and is_on_floor():
    var speed = .01
    if sprinting and not _crouched:
      speed *= SPRINT_SPEED*2.0
    var t = Time.get_ticks_msec()
    var prev = _head_bob((t-delta*1000.0)*speed)
    var base = _head_bob(t*speed)
    var height_offset = 0.5
    
    if is_zero_approx(input_dir.y):
      height_offset /= 4.0
    
    camera.v_offset = base*.05
    
    const threshold = -0.99
    if prev > threshold and base < threshold:
      var sound = StreamData.new()
      sound.parent = self
      sound.stream = preload("res://audio/dirt-footstep01.ogg")
      sound.pitch_variance = 0.1
      AudioManager.play(sound)
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
    sound.pitch_variance = 0.1
    AudioManager.play(sound)
    velocity.y = jump_height
    _cvel += Vector3.UP*2.0
    _fall_time = 0.0
    
  #if Input.is_action_pressed("crouch") or (_crouched and crouch_casts.any(func(cast): return cast.is_colliding())):
    #if is_on_floor():
      #$CollisionShape3D.shape.height = _crouched_collider_height
      #_crouched = true
  #else:
    #$CollisionShape3D.shape.height = _base_collider_height
    #_crouched = false

  if is_on_ceiling():
    velocity.y = -.01

  var decel = DECEL
  var accel = ACCEL
      
  if not is_on_floor():
    accel = 0.5
    decel = 0.5
  
  var direction = camera.global_transform.basis.x * input_dir.x
  direction += camera.global_transform.basis.z * input_dir.y
  var target_speed = max(velocity.length(), speed)
  if direction:
    velocity.x = move_toward(velocity.x, direction.x * target_speed, accel)
    velocity.z = move_toward(velocity.z, direction.z * target_speed, accel)
  else:
    velocity.x = move_toward(velocity.x, 0, decel)
    velocity.z = move_toward(velocity.z, 0, decel)
  move_and_slide()
