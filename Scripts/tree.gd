extends StaticBody2D

class_name TreeObject

var wood_amount = 10

func gather(amount: int):
	wood_amount -= amount
	if wood_amount <= 0:
		queue_free()
