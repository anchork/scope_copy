@tool
extends EditorPlugin

const ScopeCopyMenu = preload("res://addons/scope_copy/scope_copy_context_menu.gd")

var _context_menu: EditorContextMenuPlugin


func _enter_tree() -> void:
	_context_menu = ScopeCopyMenu.new()
	add_context_menu_plugin(EditorContextMenuPlugin.CONTEXT_SLOT_SCRIPT_EDITOR_CODE, _context_menu)


func _exit_tree() -> void:
	if _context_menu:
		remove_context_menu_plugin(_context_menu)
		_context_menu = null
