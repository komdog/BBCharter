extends AudioStreamPlayer

var voice_bank_index: int = 0
var last_voice_bank_index: int = 0
var current_bank: Array
var current_bank_sound_index: int

func _ready() -> void:
	Events.chart_loaded.connect(_on_chart_loaded)
	Events.hit_note.connect(_on_hit_note)
	Events.miss_note.connect(_on_miss_note)

func _on_chart_loaded():
	stream = null
	voice_bank_index = 0
	last_voice_bank_index = 0
	change_bank(voice_bank_index)

func _physics_process(_delta):
	if Save.keyframes.has('voice_bank') and Save.keyframes['voice_bank'].size() > 0:
		var arr = Save.keyframes['voice_bank'].filter(func(loop): return Global.song_pos >= loop['timestamp'])
		voice_bank_index = arr.size()
		if voice_bank_index != last_voice_bank_index:
			last_voice_bank_index = voice_bank_index
			change_bank(voice_bank_index-1)
	
func change_bank(idx):
	if !Save.keyframes.has('voice_bank'): return
	if Save.keyframes['voice_bank'].is_empty(): return
	if Save.keyframes['voice_bank'].size() <= idx: return

	var bank = Save.keyframes['voice_bank'][idx]
	if !bank.has('voice_paths'): return 
	if bank['voice_paths'].is_empty(): return 

	current_bank.clear()
	for voice_file in bank['voice_paths']:
		current_bank.append(Assets.get_asset(voice_file))

func _on_hit_note(data) -> void:
	if data.has('trigger_voice'):
		if current_bank.size() > 0 and data['trigger_voice'] == true:
			current_bank_sound_index = wrapi(current_bank_sound_index + 1, 0, current_bank.size())
			stream = current_bank[current_bank_sound_index]
			play()

func _on_miss_note(data) -> void:
	if data.has('trigger_voice'):
		if current_bank.size() > 0 and data['trigger_voice'] == true:
			current_bank_sound_index = wrapi(current_bank_sound_index - 1, 0, current_bank.size())
