extends Control

@onready var panel = $Panel
@onready var titleLabel = $Panel/Title
@onready var descriptionLabel = $Panel/Description

func show_tooltip(title: String, description: String):
	titleLabel.text = title
	descriptionLabel.text = description
	
	show()
	

func hide_tooltip():
	hide()
