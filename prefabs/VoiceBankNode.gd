extends LineEdit

# I dunno how else to do this
func _on_delete_button_up():
	queue_free()
