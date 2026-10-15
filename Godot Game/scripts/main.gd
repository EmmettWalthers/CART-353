extends Control

var planes: Dictionary = {}
	
var planes_landed := 0
var plane_ready = false

@onready var planes_counter: Label = $PanelContainer/VBoxContainer/PlanesCounter
@onready var land_button: Button = $PanelContainer/VBoxContainer/HBoxContainer/LandButton
@onready var arrival_timer: Timer = $ArrivalTimer
@onready var plane_label: Label = $PanelContainer/VBoxContainer/HBoxContainer/PlaneLabel
@onready var fuel_timer: Timer = $FuelTimer
@onready var planes_list: VBoxContainer = $PanelContainer/VBoxContainer/PlanesList

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
	for i in range(3):
		spawn_plane()
	land_button.disabled = false
	plane_ready = true
	land_button.text = str("Land Plane")
	
func spawn_plane():
	var plane_number = "A" + str(randi_range(100, 199))
	var fuel_amount = randi_range(25, 75)
	planes[plane_number] = {"fuel": fuel_amount, "status": "Waiting"}
	fuel_timer.start()
	update_planes_list()
	
func _on_fuel_timer_timeout() -> void:
	if !planes.is_empty():
		for plane in planes:
			planes[plane]["fuel"] -= 1
	update_planes_list()
	
func update_planes_list():
	for child in planes_list.get_children():
		child.queue_free()
	
	for plane in planes:
		var label = Label.new()
		label.add_theme_font_size_override("font_size", 32)
		label.text = plane + " | Fuel: " + str(planes[plane]["fuel"]) + "% | " + planes[plane]["status"]
		planes_list.add_child(label)
