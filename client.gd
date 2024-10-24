extends Node

var peer = ENetMultiplayerPeer.new()
@export var PlayerScene: PackedScene
var clientReady = false
@export var gameSpawnLocation: NodePath

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	pass # Replace with function body.

func _on_peer_connected(id: int) -> void:
	var p = PlayerScene.instantiate()
	get_node(gameSpawnLocation).add_child(p)
	p.name = str(id)

	p.get_node("AudioManager").setupAudio(id)

func _on_peer_disconnected(id: int) -> void:
	pass

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
	get_node(gameSpawnLocation).add_child(p)
	p.name = str(multiplayer.get_unique_id())

	p.get_node("AudioManager").setupAudio(multiplayer.get_unique_id())
	clientReady = true
	pass # Replace with function body.
