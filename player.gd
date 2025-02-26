extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
@onready var camera_2d: Camera2D = $Camera2D
@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $Sprite2D/AnimationPlayer
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var label: Label = $Label

var edelta : float = 0
var attacking : bool = true 

func _ready() -> void:
	label.text = str(name)
	camera_2d.enabled=is_multiplayer_authority()
	get_tree().process_frame.connect(_each_frame)
	
func _physics_process(delta: float) -> void:
	edelta=delta
	if is_multiplayer_authority():
		# Add the gravity.
		#if not is_on_floor():
			#velocity += get_gravity() * delta

		## Handle jump.
		#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			#velocity.y = JUMP_VELOCITY
		
		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var directionX := Input.get_axis("ui_left", "ui_right")
		var directionY := Input.get_axis("ui_up", "ui_down")
		if directionX:
			velocity.x = directionX * SPEED
			if velocity.x <0:
				sprite.flip_h=true
			else:
				sprite.flip_h=false
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
		if directionY:
			velocity.y = directionY * SPEED
		else:
			velocity.y = move_toward(velocity.y, 0, SPEED)
			
		if velocity!=Vector2.ZERO and !attacking:
			animation_player.play("walk")
		elif !attacking:
			animation_player.play("idle")

		# Handle attack.
		if Input.is_action_just_pressed("attack"):
			print("Attcking")
			attacking = true
			animation_player.play("attack_1")
			await animation_player.animation_finished
			attacking = false

		if Input.is_action_just_pressed("SwitchMat"):
			rpc("changeMat", "name")
			print("Change Mat pressed for " + str(name))
			
		move_and_slide()

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())
	$Camera2D.enabled=is_multiplayer_authority()
	
@rpc("unreliable","any_peer","call_local") func updatePos (id, pos, animation, flip):
	if !is_multiplayer_authority():
		if name == id:
			position = lerp (position, pos, edelta * 15)
			animation_player.play(animation)
			sprite.flip_h=flip
			
func _each_frame():
	if is_multiplayer_authority():
		rpc("updatePos", name, position,animation_player.current_animation, sprite.flip_h)

@rpc("any_peer","call_local") func changeMat(_id):
	if !is_multiplayer_authority():
		print("Change Mat pressed for " + str(_id))
