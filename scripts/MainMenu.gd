extends Control

onready var TestMap0B : Button = get_node("AspectRatioContainer/MarginContainer/VBoxContainer/TestMap0B")
onready var TestMap1B : Button = get_node("AspectRatioContainer/MarginContainer/VBoxContainer/TestMap1B")
onready var TestMap2B : Button = get_node("AspectRatioContainer/MarginContainer/VBoxContainer/TestMap2B")
onready var ExitGameB : Button = get_node("AspectRatioContainer/MarginContainer/VBoxContainer/ExitGameB")

func _ready():
	TestMap0B.grab_focus()

func _on_TestMap0B_pressed():
	get_tree().change_scene("res://objects/TestMap1.tscn")

func _on_TestMap1B_pressed():
	get_tree().change_scene("res://objects/TestMap.tscn")

func _on_TestMap2B_pressed():
	get_tree().change_scene("res://objects/TestMap2.tscn")

func _on_ExitGameB_pressed():
	get_tree().quit()
