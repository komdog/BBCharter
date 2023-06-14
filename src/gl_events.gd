extends Node

signal project_loaded()
signal song_loaded()
signal chart_loaded()
signal difficulty_created()
signal difficulty_renamed(stuff)
signal difficulty_deleted(index)

signal update_notespeed()
signal update_selection(here)
signal update_snapping(index)

signal notify()
signal popups_opened()
signal popups_closed()

signal hit_note()
signal horny_mode()
signal miss_note()

signal note_created()
signal tool_used_before(note)
signal tool_used_after(note)

signal add_animation_to_timeline(asset_path)
