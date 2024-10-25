extends Node

@onready var input: AudioStreamPlayer
var index: int
var effect: AudioEffectCapture
var playback: AudioStreamGeneratorPlayback
@export var outputPath: NodePath
var inputThreshold: float = 0.005
var receiveBuffer := PackedFloat32Array()

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
	playback = get_node(outputPath).get_stream_playback()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_multiplayer_authority() and multiplayer.get_peers().size() > 0:
		processMic()
	elif !is_multiplayer_authority():
		print("Not authority")
	elif multiplayer.get_peers().size() == 0:
		print("No peers")
	processVoice()
	pass

func processMic():
	var sterioData: PackedVector2Array = effect.get_buffer(effect.get_frames_available())

	if sterioData.size() > 0:
		var data = PackedFloat32Array()
		data.resize(sterioData.size())
		var maxAmplitude := 0.0

		for i in range(sterioData.size()):
			# average the two channels
			var value = (sterioData[i].x + sterioData[i].y) / 2.0
			maxAmplitude = max(maxAmplitude, value)
			data[i] = value
		
		# loud enough then send to server
		if maxAmplitude < inputThreshold:
			return
		
		sendData.rpc(data)

func processVoice():
	if receiveBuffer.size() <= 0:
		return

	for i in range(min(playback.get_frames_available(), receiveBuffer.size())):
		# input don't have left or right channel, so we use the same value for both
		playback.push_frame(Vector2(receiveBuffer[0], receiveBuffer[0]))
		receiveBuffer.remove_at(0)

@rpc("any_peer", "call_remote", "unreliable_ordered")
func sendData(data: PackedFloat32Array):
	receiveBuffer.append_array(data)
