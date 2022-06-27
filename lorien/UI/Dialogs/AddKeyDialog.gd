extends WindowDialog

# -------------------------------------------------------------------------------------------------
export var action_name: String
export var readable_action_name: String

# -------------------------------------------------------------------------------------------------
var _pending_bind_event = null

# -------------------------------------------------------------------------------------------------
func _process(delta):
	$VBoxContainer/EventText.text = "Action: %s" % readable_action_name

# -------------------------------------------------------------------------------------------------
func _action_for_event(event: InputEvent):
	for action in Utils.bindable_actions():
		if InputMap.action_has_event(action, event):
			return action
	return null

# -------------------------------------------------------------------------------------------------
func _input(event: InputEvent) -> void:
	if ! visible or $ConfirmRebind.visible:
		return
	
	if event is InputEventKey && event.is_pressed():
		get_tree().set_input_as_handled()
		
		if KEY_MODIFIER_MASK & event.scancode != 0:
			return

		var event_type := InputEventKey.new()
		event_type.scancode = event.scancode
		event_type.alt = event.alt
		event_type.shift = event.shift
		event_type.control = event.control
		event_type.meta = event.meta
		event_type.command = event.command
		
		var _conflicting_action = _action_for_event(event_type)
		
		_pending_bind_event = event_type
		if _conflicting_action && _conflicting_action != action_name:
			$ConfirmRebind.dialog_text = "'{event_str}' already is bound to {action_str}.\n\nDo you want to rebind?".format({
				"event_str": OS.get_scancode_string(event_type.get_scancode_with_modifiers()),
				"action_str": Utils.translate_action(action_name)
			})
			$ConfirmRebind.popup_centered()
		else:
			_finish_rebind()

# -------------------------------------------------------------------------------------------------
func _on_ConfirmRebind_confirmed():
	_finish_rebind()

# -------------------------------------------------------------------------------------------------
func _finish_rebind():
	for action in Utils.bindable_actions():
		if InputMap.action_has_event(action, _pending_bind_event):
			InputMap.action_erase_event(action, _pending_bind_event)
	InputMap.action_add_event(action_name, _pending_bind_event)
	visible = false
