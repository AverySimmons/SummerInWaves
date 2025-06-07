extends VSlider

@export var bus_name = ""

var bus_index: int

func _ready() -> void:
	bus_index = AudioServer.get_bus_index(bus_name)
<<<<<<< Updated upstream
<<<<<<< Updated upstream
	value = AudioServer.get_bus_volume_db(bus_index)

func _on_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(bus_index, value)
=======
=======
>>>>>>> Stashed changes
	value = db_to_linear(AudioServer.get_bus_volume_db(bus_index))

func _on_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
