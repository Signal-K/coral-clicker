extends PanelContainer

@onready var goal_label: RichTextLabel = $Margin/VBox/GoalLabel
@onready var turns_label: Label = $Margin/VBox/TurnsLabel

func update_objective(species: String, target: int, turns_left: int) -> void:
	goal_label.text = "[center][b]Mission Reef[/b]\nGrow [b]%s[/b] to [b]%d[/b][/center]" % [species, target]
	if turns_left == 1:
		turns_label.text = "1 reef turn remaining"
	else:
		turns_label.text = "%d reef turns remaining" % turns_left
