extends PopupMenu

enum {GITHUB,DISCORD}

func _on_id_pressed(id: int):
	match id:
		GITHUB:
			OS.shell_open("https://github.com/KirbyKid256/BBCharter")
		DISCORD:
			OS.shell_open("https://discord.gg/beatbanger")
