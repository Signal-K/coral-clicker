extends Control

const UITheme = preload("res://ui_theme.gd")

signal next_pressed
signal replay_pressed
signal home_pressed

@onready var _bg: ColorRect = $Bg
@onready var _title: Label = $Layout/Scroll/ContentMargin/Content/TitleSection/TitleLabel
@onready var _perf_card: PanelContainer = $Layout/Scroll/ContentMargin/Content/CardsRow/PerfCard
@onready var _compare_card: PanelContainer = $Layout/Scroll/ContentMargin/Content/CardsRow/CompareCard
@onready var _footer: PanelContainer = $Layout/Footer
@onready var _next_btn: Button = %NextButton
@onready var _home_btn: Button = %HomeButton
@onready var _replay_btn: Button = %ReplayButton

func setup(populations: Dictionary, targets: Dictionary,
		turns_used: int, turn_limit: int, reward_coins: int,
		subject_image_path: String = "") -> void:
	var bonus: int = max(0, (turn_limit - turns_used) * 5)
	var total: int = reward_coins + bonus

	%TurnsValue.text = str(turns_used)
	%TurnsMax.text = "/ %d LIMIT" % turn_limit
	%CoinsValue.text = "+%d" % reward_coins
	%BonusValue.text = "+%d" % bonus
	%BonusBox.visible = bonus > 0
	%TotalValue.text = str(total)

	var met: int = 0
	for sid in targets.keys():
		if populations.get(sid, 0) >= targets[sid]:
			met += 1
	%SummaryLabel.text = "%d / %d species at target" % [met, targets.size()]

	if subject_image_path != "":
		var tex := load(subject_image_path)
		if tex:
			%ZooniverseImage.texture = tex

	var grid: GridContainer = %SpeciesGrid
	for child in grid.get_children():
		child.queue_free()
	for sid in populations.keys():
		var count: int = populations[sid]
		if count <= 0:
			continue
		var sprite_path := "res://assets/sprites/%s_card_frame_00.png" % sid
		var tex := load(sprite_path)
		if not tex:
			continue
		for _i in range(min(count, 3)):
			var tr := TextureRect.new()
			tr.texture = tex
			tr.custom_minimum_size = Vector2(90, 90)
			tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			grid.add_child(tr)

func _ready() -> void:
	_apply_theme()
	_add_holographic_grid()
	
	_next_btn.pressed.connect(func(): next_pressed.emit())
	_replay_btn.pressed.connect(func(): replay_pressed.emit())
	_home_btn.pressed.connect(func(): home_pressed.emit())

func _apply_theme() -> void:
	_bg.color = UITheme.BG
	
	# Title styling
	_title.add_theme_color_override("font_color", UITheme.PRIMARY)
	_title.add_theme_font_size_override("font_size", UITheme.FS_3XL)
	_title.add_theme_color_override("font_shadow_color", Color(UITheme.PRIMARY, 0.4))
	_title.add_theme_constant_override("shadow_outline_size", 12)
	
	# Card styling (Bento look)
	_perf_card.add_theme_stylebox_override("panel", UITheme.panel(UITheme.SURFACE, UITheme.OUTLINE_VAR, 1, UITheme.R_LG))
	_compare_card.add_theme_stylebox_override("panel", UITheme.panel(UITheme.SURFACE, UITheme.OUTLINE_VAR, 1, UITheme.R_LG))
	
	# Metrics highlights
	%TurnsValue.add_theme_color_override("font_color", UITheme.PRIMARY)
	%TotalValue.add_theme_color_override("font_color", UITheme.PRIMARY)
	%BonusBox.add_theme_stylebox_override("panel", UITheme.pill(UITheme.SURF_HIGH, UITheme.PRIMARY, 1))
	
	# Footer and Buttons
	_footer.add_theme_stylebox_override("panel", UITheme.panel(UITheme.SURF_LOW, UITheme.OUTLINE_VAR, 1, 0))
	_next_btn.add_theme_stylebox_override("normal", UITheme.btn_primary_normal())
	_next_btn.add_theme_stylebox_override("hover", UITheme.btn_primary_normal())
	_next_btn.add_theme_stylebox_override("pressed", UITheme.btn_primary_pressed())
	_next_btn.add_theme_color_override("font_color", UITheme.ON_PRIMARY)
	
	_home_btn.add_theme_stylebox_override("normal", UITheme.btn_normal(UITheme.SURF_HIGH))
	_home_btn.add_theme_stylebox_override("hover", UITheme.btn_normal(UITheme.SURF_HIGH))
	_home_btn.add_theme_stylebox_override("pressed", UITheme.btn_pressed(UITheme.SURF_HIGH))

func _add_holographic_grid() -> void:
	var grid := Control.new()
	grid.name = "HoloGrid"
	grid.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	grid.mouse_filter = Control.MOUSE_FILTER_IGNORE
	grid.draw.connect(func():
		var step := 40.0
		var color := Color(UITheme.PRIMARY, 0.03)
		for x in range(0, int(size.x), int(step)):
			grid.draw_line(Vector2(x, 0), Vector2(x, size.y), color, 1.0)
		for y in range(0, int(size.y), int(step)):
			grid.draw_line(Vector2(0, y), Vector2(size.x, y), color, 1.0)
	)
	add_child(grid)
	move_child(grid, 1) # Above Bg
