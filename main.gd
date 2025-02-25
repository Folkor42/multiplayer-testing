extends Node2D

@onready var host: Button = $Host
@onready var join: Button = $Join
@onready var camera_2d: Camera2D = $Camera2D

var peer = ENetMultiplayerPeer.new()
@export var player_scene : PackedScene


func _ready() -> void:
	host.pressed.connect (_on_host_pressed)
	join.pressed.connect (_on_join_pressed)
		
func _on_host_pressed() -> void:
	peer.create_server(12345)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(add_player)
	add_player()
	camera_2d.enabled=false
	pass

func _on_join_pressed() -> void:
	peer.create_client("127.0.0.1", 12345)
	multiplayer.multiplayer_peer = peer
	camera_2d.enabled = false
	pass

func exit_game(id:int)->void:
	multiplayer.peer_disconnected.connect(del_player)
	del_player(id)
	pass

func add_player( id : int = 1) -> void:
	var player = player_scene.instantiate()
	player.name = str (id)
	call_deferred("add_child",player)
	pass
	
func del_player ( id : int) -> void:
	rpc("_del_player",id)
	
@rpc("any_peer", "call_local") func _del_player(id):
	get_node(str(id)).queue_free()
