extends Node

var peer = ENetMultiplayerPeer.new()
@export var PlayerScene: PackedScene
@export var gameSpawnLocation: NodePath
var clientReady = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	pass # Replace with function body.

func _on_peer_connected(id: int) -> void:
	print("Peer connected with id: ", id)
	var p = PlayerScene.instantiate()
	get_node(gameSpawnLocation).add_child(p)
	p.name = str(id)

	p.get_node("AudioManager").setupAudio(id)

func _on_peer_disconnected(id: int) -> void:
	print("Peer disconnected with id: ", id)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if clientReady:
		peer.poll()

func _on_connect_to_server_button_down() -> void:
	#var error: int = peer.create_client("127.0.0.1", 8910)
	var error: int = peer.create_client("spatial-audio-demo-2d.fly.dev", 8910)
	if error:
		print("Failed to create client: ", error)
		return
	multiplayer.multiplayer_peer = peer

	# spawn player scene for this peer
	var p = PlayerScene.instantiate()
	get_node(gameSpawnLocation).add_child(p)
	p.name = str(multiplayer.get_unique_id())

	p.get_node("AudioManager").setupAudio(multiplayer.get_unique_id())
	clientReady = true
	print("Client ready")
	pass # Replace with function body.
