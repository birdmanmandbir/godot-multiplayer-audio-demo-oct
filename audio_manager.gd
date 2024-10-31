extends Node

@onready var input: AudioStreamPlayer
var mic_bus: int
var mic_capture: AudioEffectOpusChunked
@export var outputPath: NodePath

var outputstreamopuschunked: AudioStreamOpusChunked

var packets_received = 0
var packets_sent = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert($Input.bus == "Record")
	pass

func setupAudio(id):
	input = $Input
	set_multiplayer_authority(id)
	
	if is_multiplayer_authority():
		mic_bus = AudioServer.get_bus_index("Record")
		mic_capture = AudioServer.get_bus_effect(mic_bus, 0)
	
	# remember to enable autoplay for the output
	outputstreamopuschunked = get_node(outputPath).get_stream()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_multiplayer_authority():
		processMic()

func processMic():
	while mic_capture.chunk_available():
		var packet = mic_capture.read_opus_packet(PackedByteArray())
		mic_capture.drop_chunk()
		# TODO: add maxAmplitude filter?
		if multiplayer.multiplayer_peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED:
			sendData.rpc(packet)
			packets_sent += 1
			if (packets_sent % 100) == 0:
				print("Packets sent: ", packets_sent, " from id ", multiplayer.get_unique_id())

@rpc("any_peer", "call_remote", "unreliable_ordered")
func sendData(packet: PackedByteArray):
	packets_received += 1
	if (packets_received % 100) == 0:
		print("Packets received: ", packets_received, " from id ", multiplayer.get_unique_id())
	outputstreamopuschunked.push_opus_packet(packet, 0, 0)
