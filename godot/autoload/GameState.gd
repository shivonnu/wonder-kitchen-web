extends Node

signal scene_changed(scene: String)
signal inventory_changed
signal flags_changed
signal dialogue_changed
signal fading_changed(on: bool)
signal hand_changed

const SAVE_PATH := "user://hoshishio-save-v1.json"
const RECIPE: Array[String] = ["memo", "potato", "onion", "moonMilk", "starSalt"]
const START_DIALOGUE := {
	"speaker": "しおん",
	"text": "夜のキッチンだよ。気になるところを、どんどん触ってみて。",
}

var scene: String = "title"
var items: Array[String] = []
var flags: Array[String] = []
var dialogue: Dictionary = START_DIALOGUE.duplicate()
var fading: bool = false
var hand: String = ""
var has_save: bool = false

func _ready() -> void:
	has_save = FileAccess.file_exists(SAVE_PATH)


func has_item(id: String) -> bool:
	return id in items


func has_flag(id: String) -> bool:
	return id in flags


func can_cook() -> bool:
	for id in RECIPE:
		if id not in items:
			return false
	return true


func say(speaker: String, text: String) -> void:
	dialogue = {"speaker": speaker, "text": text}
	dialogue_changed.emit()
	persist()


func set_hand(next: String) -> void:
	if hand == next:
		hand = ""
	else:
		hand = next
	hand_changed.emit()


func clear_hand() -> void:
	hand = ""
	hand_changed.emit()


func start_new() -> void:
	_wipe_save()
	items.clear()
	flags.clear()
	hand = ""
	dialogue = START_DIALOGUE.duplicate()
	has_save = true
	inventory_changed.emit()
	flags_changed.emit()
	dialogue_changed.emit()
	hand_changed.emit()
	await change_scene("kitchen")
	persist()


func continue_game() -> void:
	var saved := _load_save()
	if saved.is_empty():
		return
	items.clear()
	for id in saved.get("items", []):
		items.append(str(id))
	flags.clear()
	for id in saved.get("flags", []):
		flags.append(str(id))
	dialogue = saved.get("dialogue", START_DIALOGUE.duplicate())
	hand = ""
	inventory_changed.emit()
	flags_changed.emit()
	dialogue_changed.emit()
	hand_changed.emit()
	var next := str(saved.get("scene", "kitchen"))
	if next == "title":
		next = "kitchen"
	await change_scene(next)


func reset() -> void:
	_wipe_save()
	items.clear()
	flags.clear()
	hand = ""
	dialogue = START_DIALOGUE.duplicate()
	has_save = false
	inventory_changed.emit()
	flags_changed.emit()
	dialogue_changed.emit()
	hand_changed.emit()
	await change_scene("title")


func go_to(next: String, speaker := "", text := "") -> void:
	if speaker != "":
		say(speaker, text)
	await change_scene(next)
	persist()


func change_scene(next: String) -> void:
	if next == scene:
		return
	fading = true
	fading_changed.emit(true)
	await get_tree().create_timer(0.28).timeout
	scene = next
	fading = false
	scene_changed.emit(scene)
	fading_changed.emit(false)


func click_hotspot(spot: Dictionary) -> void:
	if spot.has("showWhen"):
		for f in spot["showWhen"]:
			if str(f) not in flags:
				return
	if spot.has("hideWhen"):
		for f in spot["hideWhen"]:
			if str(f) in flags:
				return
	if spot.has("requireItems"):
		for id in spot["requireItems"]:
			if str(id) not in items:
				say("しおん", str(spot.get("missingText", "まだ足りないものがあるみたい。")))
				return

	var actions: Array = spot.get("actions", [])
	var gives: Array = []
	var has_go := false
	for a in actions:
		if str(a.get("type", "")) == "give":
			gives.append(a)
		if str(a.get("type", "")) == "go":
			has_go = true
	if gives.size() > 0:
		var all_have := true
		for a in gives:
			if str(a.get("item", "")) not in items:
				all_have = false
				break
		if all_have and not has_go:
			if scene == "moonCave":
				say("しおん", "月牛乳はもう持ってるよ。畑へもどろう。")
				call_deferred("go_to", "moonField")
				return
			say("しおん", "それは、もう持っているよ。")
			return

	var next_scene := ""
	var speaker := str(dialogue.get("speaker", "しおん"))
	var text := str(dialogue.get("text", ""))
	var picked := false
	for a in actions:
		match str(a.get("type", "")):
			"say":
				speaker = str(a.get("speaker", speaker))
				text = str(a.get("text", text))
			"give":
				var item := str(a.get("item", ""))
				if item != "" and item not in items:
					items.append(item)
					picked = true
				speaker = str(a.get("speaker", speaker))
				text = str(a.get("text", text))
			"flag":
				var flag := str(a.get("flag", ""))
				if flag != "" and flag not in flags:
					flags.append(flag)
				speaker = str(a.get("speaker", speaker))
				text = str(a.get("text", text))
			"go":
				next_scene = str(a.get("scene", ""))
				if str(a.get("text", "")) != "":
					speaker = str(a.get("speaker", "しおん"))
					text = str(a.get("text", text))

	if picked:
		var hint := _next_step_hint()
		if hint != "":
			text = "%s %s" % [text, hint]

	dialogue = {"speaker": speaker, "text": text}
	dialogue_changed.emit()
	inventory_changed.emit()
	flags_changed.emit()
	persist()
	if next_scene != "":
		call_deferred("go_to", next_scene)


func _next_step_hint() -> String:
	if can_cook():
		return "そろったね。上の『料理をはじめる』を押して。"
	if scene == "moonCave":
		if "starSalt" not in items:
			return "星しおはキッチンの壺にあるよ。『もどる』で畑へ戻ろう。"
		return "『もどる』でキッチンまで帰って、料理しよう。"
	return ""


func persist() -> void:
	var data := {
		"scene": scene,
		"items": items,
		"flags": flags,
		"dialogue": dialogue,
	}
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(data))
		has_save = true


func _load_save() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return {}
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if f == null:
		return {}
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return {}
	return parsed


func _wipe_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		var d := DirAccess.open("user://")
		if d:
			d.remove("hoshishio-save-v1.json")
