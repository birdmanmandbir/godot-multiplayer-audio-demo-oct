extends Node

var peer = ENetMultiplayerPeer.new()
@export var PlayerScene: PackedScene

var serverIsReady = false

@export var gameSpawnLocation: NodePath

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

func _on_peer_connected(id: int) -> void:
	print("Peer connected with id: ", id)

func _on_peer_disconnected(id: int) -> void:
	print("Peer disconnected with id: ", id)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# keep the server running
	if serverIsReady:
		peer.poll()
	pass

func _on_host_button_down():
	var error = peer.create_server(8910)
	if error != OK:
		print("Failed to create server: ", error)
		return

	serverIsReady = true
	print("Server is ready")
	multiplayer.multiplayer_peer = peer

	var p = PlayerScene.instantiate()
	get_node(gameSpawnLocation).add_child(p)
	# 1 for godot server
	p.name = str(1)

	p.get_node("AudioManager").setupAudio(1)
	pass
