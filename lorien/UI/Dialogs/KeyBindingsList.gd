extends GridContainer

const KEYBINDINGS_LINE_SCENE = preload("res://UI/Dialogs/KeyBindingsLine.tscn")

var lines := []

# -------------------------------------------------------------------------------------------------
func _ready():
	$"../../AddKeyDialog".connect("hide", self, "_bind_key_dialog_hidden")
	_populate_input_list()
	GlobalSignals.connect("language_changed", self, "_populate_input_list")

# -------------------------------------------------------------------------------------------------
func _populate_input_list():
	for c in get_children():
		remove_child(c)
	
	for action in Utils.bindable_actions():
		var translated_action = Utils.translate_action(action)
		var shortcuts = []
		for _event in InputMap.get_action_list(action):
			if _event is InputEventKey:
				var event = _event as InputEventKey
				shortcuts.append(event)

		_new_keybinding_entry(action, translated_action, shortcuts)

# -------------------------------------------------------------------------------------------------
func _new_keybinding_entry(action_name: String, readable_name: String, events: Array) -> void:
	var new_line: Node = KEYBINDINGS_LINE_SCENE.instance()

	lines.append({"action_name": action_name})
	for child in new_line.get_children():
		child = child as Node
		
		child.set_keybindings_data({
			"action": action_name,
			"readable_name": readable_name,
			"events": events,
		})
		new_line.remove_child(child)
		add_child(child)
		
		child.connect("modified_binding", self, "_modify_keybinding", [action_name])
		child.connect("bind_new_key", self, "_bind_new_key", [action_name])

# -------------------------------------------------------------------------------------------------
func _modify_keybinding(bindings_data: Dictionary, action_name: String) -> void:
	InputMap.action_erase_events(action_name)
	for e in bindings_data["events"]:
		InputMap.action_add_event(action_name, e)
	_populate_input_list()
	Settings.reload_locales()

# -------------------------------------------------------------------------------------------------
func _bind_new_key(action_name: String) -> void:
	$"../../AddKeyDialog".action_name = action_name
	$"../../AddKeyDialog".readable_action_name = Utils.translate_action(action_name)
	$"../../AddKeyDialog".popup_centered()

# -------------------------------------------------------------------------------------------------
func _bind_key_dialog_hidden() -> void:
	_populate_input_list()
	Settings.reload_locales()