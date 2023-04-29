extends Control

func _ready():
	Events.notify.connect(_on_notify)

func _on_notify(header: String, sub_header: String, image_path: String):
	$Header.text = header
	$SubHeader.text = "[wave amp=30 freq=10]%s[/wave]" % sub_header
	$Icon.texture = Global.load_texture(image_path)
	$AnimationPlayer.stop()
	$AnimationPlayer.play("Notify")

