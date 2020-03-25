extends VBoxContainer

onready var language_select = $Languages/LanguageList


const LANGUAGES = {
	"en": "English",
	"fr": "Français"
}


var language
var controls_helper : bool setget set_controls_helper


# Called when the node enters the scene tree for the first time.
func _ready():
	for key in LANGUAGES:
		language_select.add_item( LANGUAGES[key] )
	reload()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func reload():
	
	language = Configuration.Settings.Game.Language
	set_controls_helper(Configuration.Settings.Game.ControlsHelper)
	
	var language_text = LANGUAGES[language]
	
	for index in language_select.get_item_count():
		var text = language_select.get_item_text(index)
		if text == language_text:
			language_select.select(index)


func apply():
	Configuration.Settings.Game.Language = language
	Configuration.Settings.Game.ControlsHelper = controls_helper


func _on_languageList_item_selected(ID):
	var language_selected = language_select.get_item_text(ID)
	for key in LANGUAGES:
		if LANGUAGES[key] == language_selected:
			language = key
			return


func _on_CheckBox_toggled(button_pressed: bool):
	
	controls_helper = button_pressed
	


func set_controls_helper(value: bool):
	controls_helper = value
	$ControlsHelper/CheckBox.pressed = value
	
