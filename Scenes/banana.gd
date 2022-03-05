extends Area2D


var taken = false

func _on_body_enter(body):
	print("BANANA")
	if not taken and body is Monkey:
		taken=true
		get_parent().remove_child(self)
