extends Control


signal closed


export var enable_savegame := false setget set_enable_savegame
export var enable_close := false setget set_enable_close
export var enable_return_main_menu := false setget set_enable_return_main_menu
export var enable_quit_game := false setget set_enable_quit_game


var active := false setget set_active



# Called when the node enters the scene tree for the first time.
func _ready():
	
	set_enable_quit_game(enable_quit_game)
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _input(event):
	if active:
		if Input.is_action_just_pressed("ui_cancel"):
			emit_signal("closed")



func set_active(value):
	active = value
	if active:
		$MarginContainer/VBoxContainer/HBoxContainer/OptionsList/MenusList/VideoOptions.grab_focus()


func reload():
	for option in $MarginContainer/VBoxContainer/HBoxContainer/OptionsContainer/OptionsContainer.get_children():
		if option.has_method("reload"):
			option.reload()


func set_enable_savegame(value):
	enable_savegame = value
	#$MarginContainer/VBoxContainer/HBoxContainer/OptionsList/SaveGame.visible = value


func set_enable_close(value):
	enable_close = value
	$MarginContainer/VBoxContainer/HBoxContainer/OptionsList/ActionsList/CloseButton.visible = value


func set_enable_return_main_menu(value):
	enable_return_main_menu = value
	$MarginContainer/VBoxContainer/HBoxContainer/OptionsList/ActionsList/ReturnMainMenu.visible = value


func set_enable_quit_game(value):
	enable_quit_game = value
	if $MarginContainer != null:
		$MarginContainer/VBoxContainer/HBoxContainer/OptionsList/ActionsList/QuitGame.visible = value



func _hide_all():
	var options = $MarginContainer/VBoxContainer/HBoxContainer/OptionsContainer/OptionsContainer
	for option in options.get_children():
		option.visible = false


func _on_VideoOptions_pressed():
	_hide_all()
	$MarginContainer/VBoxContainer/HBoxContainer/OptionsContainer/OptionsContainer/OptionsVideo.visible = true
	$MarginContainer/VBoxContainer/HBoxContainer/OptionsContainer/OptionsContainer/OptionsVideo.reload()


func _on_AudioOptions_pressed():
	_hide_all()
	$MarginContainer/VBoxContainer/HBoxContainer/OptionsContainer/OptionsContainer/OptionsAudio.visible = true
	$MarginContainer/VBoxContainer/HBoxContainer/OptionsContainer/OptionsContainer/OptionsAudio.reload()


func _on_GameOptions_pressed():
	_hide_all()
	$MarginContainer/VBoxContainer/HBoxContainer/OptionsContainer/OptionsContainer/OptionsGame.visible = true
	$MarginContainer/VBoxContainer/HBoxContainer/OptionsContainer/OptionsContainer/OptionsGame.reload()


func _on_CancelButton_pressed():
	Configuration.load_settings()
	Configuration.apply_settings()


func _on_ApplyButton_pressed():
	for option in $MarginContainer/VBoxContainer/HBoxContainer/OptionsContainer/OptionsContainer.get_children():
		if option.has_method("apply"):
			option.apply()
	Configuration.apply_settings()


func _on_ApplySaveButton_pressed():
	_on_ApplyButton_pressed()
	Configuration.save_settings()


func _on_SaveGame_pressed():
	
	#save.save_game()
	pass


func _on_CloseButton_pressed():
	
	emit_signal("closed")
	


func _on_QuitGame_pressed():
	
	get_tree().quit()
	


func _on_ReturnMainMenu_pressed():
	
	if Network.is_enable():
		get_tree().get_network_peer().close_connection()
	
	Loading.change_scene("res://scenes/main_menu/MainMenu.tscn")
	get_tree().paused = false
