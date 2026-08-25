class_name LoadoutPanel
extends PanelContainer


@onready var name_label: Label = $Content/NameLabel
@onready var health_label: Label = $Content/HealthLabel
@onready var speed_label: Label = $Content/SpeedLabel
@onready var capacity_label: Label = $Content/CapacityLabel
@onready var equipped_modules_label: Label = $Content/EquippedModulesLabel


func display_scrapture(scrapture: ScraptureRuntime) -> void:
	name_label.text = scrapture.definition.display_name

	health_label.text = (
		"Health: "
		+ str(scrapture.current_health)
		+ " / "
		+ str(scrapture.get_final_max_health())
	)

	speed_label.text = (
		"Speed: "
		+ str(scrapture.get_final_speed())
	)

	capacity_label.text = (
		"Capacity: "
		+ str(scrapture.get_used_capacity())
		+ " / "
		+ str(scrapture.definition.attachment_capacity)
	)

	equipped_modules_label.text = "Equipped Modules:"

	if scrapture.equipped_modules.is_empty():
		equipped_modules_label.text += "\nNone"
		return

	for module: ModuleDefinition in scrapture.equipped_modules:
		equipped_modules_label.text += "\n" + module.display_name
