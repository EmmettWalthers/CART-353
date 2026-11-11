extends Control

var planes: Dictionary = {}
	
var planes_landed = 0
var planes_crashed = 0
var plane_ready = false
var runway_busy = false
var planes_waiting = 0

@onready var planes_crashed_label: Label = $PanelContainer/VBoxContainer/PlanesCrashed
@onready var planes_counter: Label = $PanelContainer/VBoxContainer/PlanesCounter
@onready var arrival_timer: Timer = $ArrivalTimer
@onready var fuel_timer: Timer = $FuelTimer
@onready var planes_list: VBoxContainer = $PanelContainer/VBoxContainer/PlanesList
@onready var runway_timer: Timer = $RunwayTimer
@onready var runway_label: Label = $PanelContainer/VBoxContainer/RunwayLabel

func _on_arrival_timer_timeout() -> void:
	spawn_plane()
	plane_ready = true
	arrival_timer.start(randf_range(5.0, 10.0))
	
func spawn_plane():
	if planes_waiting < 5:
		var plane_number = "A" + str(randi_range(100, 199))
		
		while planes.has(plane_number):
			plane_number = "A" + str(randi_range(100, 199))
			
		var fuel_amount = randi_range(25, 50)
		
		planes[plane_number] = {"fuel": fuel_amount, "status": "Waiting"}
		
		if fuel_timer.is_stopped():
			fuel_timer.start()
		
		planes_waiting += 1
			
		update_planes_list()
	
func _on_fuel_timer_timeout() -> void:
	var crashed_planes = []
	
	for plane in planes:
		planes[plane]["fuel"] -= 1
		
		if planes[plane]["fuel"] <= 0:
			crashed_planes.append(plane)
		
	for plane in crashed_planes:
		planes.erase(plane)
		planes_crashed += 1
		planes_crashed_label.text = str("Planes Crashed: " + str(planes_crashed))
	
	update_planes_list()
	
func update_planes_list():
	for child in planes_list.get_children():
		child.queue_free()
	
	for plane in planes:
		var hbox = HBoxContainer.new()
		var label = Label.new()
		var button = Button.new()
		
		label.add_theme_font_size_override("font_size", 32)
		label.text = plane + " | Fuel: " + str(planes[plane]["fuel"]) + "% | " + planes[plane]["status"]
		
		button.add_theme_font_size_override("font_size", 32)
		button.text = " LAND "
		button.disabled = runway_busy
		button.pressed.connect(land_plane.bind(plane))
		
		hbox.add_theme_constant_override("separation", 20)
		hbox.add_child(label)
		hbox.add_child(button)
		
		planes_list.add_child(hbox)

func land_plane(plane):
	if runway_busy:
		return
	else:
		planes.erase(plane)
		planes_landed += 1
		planes_waiting -= 1
		planes_counter.text = str("Planes Landed: ") + str(planes_landed)
		runway_busy = true
		update_planes_list()
		runway_label.text = str("Runway: Occupied")
		runway_timer.start()

func _on_runway_timer_timeout() -> void:
	runway_busy = false
	runway_label.text = str("Runway: Available")
