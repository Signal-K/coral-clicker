extends PanelContainer

@export var species_name: String = ""
@export var common_name: String = ""
@export var category: String = "coral"
@export var cues: PackedStringArray = []
@export var caution: PackedStringArray = []

@onready var _name_label: Label = $Margin/Body/NameLabel
@onready var _common_label: Label = $Margin/Body/CommonLabel
@onready var _cue_label: Label = $Margin/Body/CueLabel
@onready var _caution_label: Label = $Margin/Body/CautionLabel
@onready var _category_badge: Label = $Margin/Body/Header/CategoryBadge

func setup(data: Dictionary) -> void:
	species_name = str(data.get("name", ""))
	common_name = str(data.get("common_name", ""))
	category = str(data.get("category", "coral"))
	cues = PackedStringArray(data.get("cues", []))
	caution = PackedStringArray(data.get("caution", []))
	_update_view()

func _ready() -> void:
	_update_view()

func _update_view() -> void:
	if not is_node_ready():
		return
	_name_label.text = species_name
	_common_label.text = common_name if not common_name.is_empty() else "Unlabeled reference"
	_category_badge.text = category.to_upper()
	_cue_label.text = "Look for: %s" % (cues[0] if not cues.is_empty() else "shape and colony pattern")
	_caution_label.text = "Watch out for: %s" % (caution[0] if not caution.is_empty() else "similar outlines")
