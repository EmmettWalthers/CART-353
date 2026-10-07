extends Control

var planes_landed := 0
var plane_ready = false
var plane_number := str("A100")
var fuel := 100

@onready var planes_counter: Label = $PanelContainer/VBoxContainer/PlanesCounter
@onready var land_button: Button = $PanelContainer/VBoxContainer/LandButton
@onready var arrival_timer: Timer = $ArrivalTimer
@onready var plane_label: Label = $PanelContainer/VBoxContainer/PlaneLabel
@onready var fuel_timer: Timer = $FuelTimer

func _ready() -> void:
	land_button.disabled = true
	land_button.text = str("Waiting for Plane")
	plane_label.text = str("")

func _on_button_pressed() -> void:
	if plane_ready:
		planes_landed += 1
		planes_counter.text = str("Planes Landed: ") + str(planes_landed)
		land_button.text = str("Waiting for Plane")
		land_button.disabled = true
		plane_ready = false
		arrival_timer.start()
		plane_label.text = str("")

func _on_arrival_timer_timeout() -> void:
	land_button.disabled = false
	plane_ready = true
	spawn_plane()
	land_button.text = str("Land Plane")
	
func spawn_plane():
	plane_number = str("A") + str(randi_range(100, 199))
	fuel = randi_range(25, 75)
	plane_label.text = str("Plane: " + plane_number + " | " + "Fuel: " + str(fuel) + "%")
	fuel_timer.start()

func _on_fuel_timer_timeout() -> void:
	if plane_ready:
		fuel -= 1
		plane_label.text = str("Plane: " + plane_number + " | " + "Fuel: " + str(fuel) + "%")
		fuel_timer.start()
	
	
