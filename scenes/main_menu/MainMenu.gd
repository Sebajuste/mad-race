extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	pass


func _on_PlayButton_pressed():
	
	var options = {
		"multiplayer": false
	}
	
	Loading.change_scene("res://scenes/main_game/MainGame.tscn", options)
	


func _on_MultiplayerButton_pressed():
	
	$CanvasLayer/GameSelection.visible = false
	$CanvasLayer/MultiplayerDiscover.visible = true
	



func _on_QuitButton_pressed():
	
	get_tree().quit()
	


func _on_MultiplayerDiscover_exited():
	
	$CanvasLayer/GameSelection.visible = true
	$CanvasLayer/MultiplayerDiscover.visible = false
	


func _on_MultiplayerDiscover_lobby_started():
	
	var options = {
		"multiplayer": true
	}
	
	Loading.change_scene("res://scenes/main_game/MainGame.tscn", options)
	

func _on_OptionsButton_pressed():
	$CanvasLayer/OptionsMenu.visible = true
	$CanvasLayer/GameSelection.visible = false


func _on_Options_closed():
	$CanvasLayer/OptionsMenu.visible = false
	$CanvasLayer/GameSelection.visible = true
