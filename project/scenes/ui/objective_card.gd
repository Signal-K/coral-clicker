extends PanelContainer

@onready var goal_label: RichTextLabel = $Margin/VBox/GoalLabel
@onready var turns_label: Label = $Margin/VBox/TurnsLabel

func update_objective(species: String, target: int, turns_left: int) -> void:
	goal_label.text = "[center]Replicate: [b]%s[/b] × [b]%d[/b][/center]" % [species, target]
	turns_label.text = "Turns: %d remaining" % turns_left
