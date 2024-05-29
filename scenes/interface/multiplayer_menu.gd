extends Control


func _ready():
	pass


func _process(delta):
	pass


func _on_host_multiplayer_pressed():
	MultiplayerHelper.host_game()


func _on_join_multiplayer_pressed():
	MultiplayerHelper.join_game($Container/MarginContainer/VBoxContainer/AddrEntry.text)
