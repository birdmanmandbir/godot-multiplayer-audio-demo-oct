extends Node2D

@export var Character: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var s = Character.instantiate()
	add_child(s)
	s.setupAudio()
	s.get_node("AudioManager").setupAudio(multiplayer.get_unique_id())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
