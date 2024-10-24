extends Node

var peer = ENetMultiplayerPeer.new()
@export var PlayerScene: PackedScene
var clientReady = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	pass # Replace with function body.

func _on_peer_connected(id: int) -> void:
	# print("Peer connected with id: ", id)
	var p = PlayerScene.instantiate()
	p.name = str(id)
	get_tree().root.add_child(p)

	p.get_node("AudioManager").setupAudio(id)

func _on_peer_disconnected(id: int) -> void:
	pass
	# print("Peer disconnected with id: ", id)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if clientReady:
		peer.poll()
	pass


func _on_connect_to_server_button_down() -> void:
	peer.create_client("127.0.0.1", 8910)
	multiplayer.multiplayer_peer = peer

	# spawn player scene for this peer
	var p = PlayerScene.instantiate()
	p.name = str(multiplayer.get_unique_id())
	get_tree().root.add_child(p)

	p.get_node("AudioManager").setupAudio(multiplayer.get_unique_id())
	clientReady = true
	pass # Replace with function body.
