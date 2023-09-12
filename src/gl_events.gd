extends Node

signal chart_loaded()
signal song_loaded()
signal project_loaded()
signal difficulty_created()
signal difficulty_renamed(stuff)
signal difficulty_deleted(index)

signal update_bpm()
signal update_notespeed()
signal update_snapping(index)

signal notify()
signal popups_opened(index)
signal popups_closed()

signal hit_note()
signal horny_mode()
signal miss_note()

signal note_created()
signal note_deleted()
signal tool_used_before(note)
signal tool_used_after(note)

signal open_image_menu(asset_path,pos)
signal open_audio_menu(asset_path,pos)
signal add_animation_to_timeline(asset_path)
signal add_effect_to_timeline(asset_path)
signal add_voicebank_to_timeline(asset_path)
