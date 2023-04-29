extends PopupMenu

enum {GITHUB,DISCORD}

func _on_id_pressed(id: int):
	match id:
		GITHUB:
			OS.shell_open("https://gitlab.bunfan.com/bunfan/public/bb-charter")
		DISCORD:
			OS.shell_open("https://discord.gg/bufan")
