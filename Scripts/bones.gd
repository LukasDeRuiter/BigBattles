extends Node2D

func _ready() -> void:
	$DespawnTimer.timeout.connect(self.queue_free)
