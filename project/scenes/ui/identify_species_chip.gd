extends Button

@export var species_id: String = ""
@export var species_name: String = ""
@export var common_name: String = ""
@export var role: String = "coral"

@onready var _name_label: Label = $Margin/Content/NameLabel
@onready var _meta_label: Label = $Margin/Content/Header/MetaLabel
@onready var _role_dot: ColorRect = $Margin/Content/Header/RoleDot

const ROLE_COLORS := {
	"coral": Color(0.322, 0.949, 0.961, 1.0),
	"fish": Color(1.000, 0.906, 0.573, 1.0),
	"stressor": Color(1.000, 0.706, 0.671, 1.0),
}

func _ready() -> void:
	toggle_mode = true
	_update_view()

func setup(data: Dictionary) -> void:
	species_id = str(data.get("id", ""))
	species_name = str(data.get("name", data.get("label", species_id)))
	common_name = str(data.get("common_name", ""))
	role = str(data.get("role", data.get("category", "coral")))
	_update_view()

func _update_view() -> void:
	if not is_node_ready():
		return
	_name_label.text = species_name.to_upper()
	_meta_label.text = common_name if not common_name.is_empty() else species_id.replace("_", " ")
	_role_dot.color = ROLE_COLORS.get(role, ROLE_COLORS["coral"])
