extends Control

const UITheme = preload("res://ui_theme.gd")

signal restart_pressed
signal home_pressed

@onready var _dim: ColorRect = $Dim
@onready var _modal: PanelContainer = $Modal
@onready var _title: Label = $Modal/ModalVBox/ModalContent/ContentVBox/HeaderRow/HeaderText/TitleLabel
@onready var _reason: Label = %ReasonLabel
@onready var _restart_btn: Button = %RestartButton
@onready var _home_btn: Button = %HomeButton

func setup(reason: String) -> void:
	var msg := reason if reason != "" else "Turn limit reached"
	_reason.text = "> FATAL ERROR: %s\n> STATUS: Classification Aborted\n_" % msg.to_upper()

func _ready() -> void:
	_apply_theme()
	_add_scanlines()
	
	_restart_btn.pressed.connect(func(): restart_pressed.emit())
	_home_btn.pressed.connect(func(): home_pressed.emit())

func _apply_theme() -> void:
	# Use UITheme for background and modal
	_dim.color = Color(UITheme.BG, 0.95)
	
	var modal_style := UITheme.panel(UITheme.SURFACE, UITheme.ERROR, 2, UITheme.R_LG)
	_modal.add_theme_stylebox_override("panel", modal_style)
	
	# Title styling
	_title.add_theme_color_override("font_color", UITheme.ERROR)
	_title.add_theme_font_size_override("font_size", UITheme.FS_3XL)
	_title.add_theme_color_override("font_shadow_color", Color(UITheme.ERROR, 0.4))
	_title.add_theme_constant_override("shadow_offset_x", 0)
	_title.add_theme_constant_override("shadow_offset_y", 0)
	_title.add_theme_constant_override("shadow_outline_size", 10)

	# Button styling
	_restart_btn.add_theme_stylebox_override("normal", UITheme.btn_danger_normal())
	_restart_btn.add_theme_stylebox_override("hover", UITheme.btn_danger_normal())
	_restart_btn.add_theme_stylebox_override("pressed", UITheme.btn_danger_pressed())
	
	_home_btn.add_theme_stylebox_override("normal", UITheme.btn_normal(UITheme.SURF_HIGH))
	_home_btn.add_theme_stylebox_override("hover", UITheme.btn_normal(UITheme.SURF_HIGH))
	_home_btn.add_theme_stylebox_override("pressed", UITheme.btn_pressed(UITheme.SURF_HIGH))

func _add_scanlines() -> void:
	var scanlines := TextureRect.new()
	scanlines.name = "Scanlines"
	scanlines.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scanlines.mouse_filter = Control.MOUSE_FILTER_IGNORE
	scanlines.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	scanlines.stretch_mode = TextureRect.STRETCH_TILE
	
	var grad := Gradient.new()
	grad.add_point(0.0, Color(0,0,0,0))
	grad.add_point(0.5, Color(0,0,0,0))
	grad.add_point(0.51, Color(0,0,0,0.1))
	grad.add_point(1.0, Color(0,0,0,0.1))
	
	var tex := GradientTexture2D.new()
	tex.gradient = grad
	tex.width = 1
	tex.height = 4
	tex.fill_from = Vector2(0, 0)
	tex.fill_to = Vector2(0, 1)
	
	scanlines.texture = tex
	add_child(scanlines)
	move_child(scanlines, 1) # Above Dim, below Modal
