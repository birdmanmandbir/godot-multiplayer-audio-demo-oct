extends Node

@onready var input: AudioStreamPlayer
var index: int
var effect: AudioEffectOpusChunked
@export var outputPath: NodePath
var inputThreshold: float = 0.005
var receiveBuffer := []

var outputstreamopuschunked: AudioStreamOpusChunked
var prefixbyteslength = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func setupAudio(id):
	input = $Input
	set_multiplayer_authority(id)
	
	if is_multiplayer_authority():
		# Set up the input stream
		input.stream = AudioStreamMicrophone.new()
		input.play()
		
		index = AudioServer.get_bus_index("Record")
		effect = AudioServer.get_bus_effect(index, 0)
	
	# remember to enable autoplay for the output
	outputstreamopuschunked = get_node(outputPath).get_stream()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_multiplayer_authority() and multiplayer.multiplayer_peer and multiplayer.multiplayer_peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTED:
		processMic()
	processVoice()
	pass

func processMic():
	var prepend = PackedByteArray()
	while effect.chunk_available():
		var opusdata: PackedByteArray = effect.read_opus_packet(prepend)
		effect.drop_chunk()
		var maxAmplitude := 0.0

		for i in range(opusdata.size()):
			# loud enough then send to server
			maxAmplitude = max(maxAmplitude, opusdata[i])
		
		if maxAmplitude < inputThreshold:
			continue
		
		sendData.rpc(opusdata)

func processVoice():
	if receiveBuffer.size() == 0:
		return

	while outputstreamopuschunked.chunk_space_available():
		var fec = 0
		outputstreamopuschunked.push_opus_packet(receiveBuffer, prefixbyteslength, fec)

@rpc("any_peer", "call_remote", "unreliable_ordered")
func sendData(data: PackedByteArray):
	receiveBuffer.append_array(data)
