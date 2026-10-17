class_name VillagerInteraction
## Talk / Gift rules. Returns the message to show; records the relationship change.

const ALREADY_TALKED: String = "We already spoke this year."
const NO_TRINKETS: String = "You have no trinkets to give."
const FALLBACK_LINES: Array[String] = ["Good day to you.", "The sky looks strange this year."]


static func talk(data: VillagerData) -> String:
	if data.talked_this_year:
		return ALREADY_TALKED
	data.talked_this_year = true
	Relationships.record_talk(data.id, data.villager_name)
	var line := _pick_line(data)
	Events.villager_spoke.emit(data.id, line)
	return line


static func can_gift() -> bool:
	return PlayerState.trinkets > 0


static func gift(data: VillagerData) -> String:
	if not PlayerState.spend_trinket():
		return NO_TRINKETS
	Relationships.record_gift(data.id, data.villager_name)
	return "%s accepts your gift." % data.villager_name


static func _pick_line(data: VillagerData) -> String:
	if data.overlord != null and not data.overlord.talk_lines.is_empty():
		return data.overlord.talk_lines.pick_random()
	return FALLBACK_LINES.pick_random()
