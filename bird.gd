extends CharacterBody2D
@onready var turnaround: Timer = $Turnaround
@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $Sprite2D/AnimationPlayer
@onready var hit_box: Area2D = $HitBox

signal Enemy_Damaged

var walk_speed : int = 20
var hp : int = 3
var edelta : float = 0

func _ready() -> void:
	velocity.x = walk_speed	
	turnaround.timeout.connect(turn_around)
	hit_box.Damaged.connect( _take_damage )
	get_tree().process_frame.connect(_each_frame)
	pass
	
func _process(_delta: float) -> void:
	edelta=_delta
	move_and_slide()
	
func turn_around()->void:
	walk_speed *= -1
	sprite.flip_h = !sprite.flip_h
	velocity.x = walk_speed	

func _take_damage ( hurt_box : HurtBox ) -> void:
	hp -= hurt_box.damage
	if hp > 0:
		print("OW")
		velocity = Vector2.ZERO
		Enemy_Damaged.emit( hurt_box )
		animation_player.play("hurt")
		await animation_player.animation_finished
		animation_player.play("idle")
		velocity.x = walk_speed
	else:
		queue_free()

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())

@rpc("unreliable","any_peer","call_local") func updatePos (id, pos, animation, flip):
	if !is_multiplayer_authority():
		if name == id:
			position = lerp (position, pos, edelta * 15)
			animation_player.play(animation)
			sprite.flip_h=flip
			
func _each_frame():
	if is_multiplayer_authority():
		rpc("updatePos", name, position,animation_player.current_animation, sprite.flip_h)
