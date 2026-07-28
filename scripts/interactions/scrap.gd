class_name Scrap #we define an new class named scrap
extends Area2D

#this line defines a signal that belongs to scrap-
#u can think of a signal like a messege that says:"i have been collected"
signal collected 

func _on_body_entered(body: Node2D) -> void: #this function recibed a signal from a body that entered its polygon
	if body.is_in_group("player"):
		collected.emit() ## this is the coommand which sends the signal
		queue_free()
