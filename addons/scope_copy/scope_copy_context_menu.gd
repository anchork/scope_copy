@tool
extends EditorContextMenuPlugin

const MENU_LABEL = "Copy with Scope (Path:Lines)"


func _popup_menu(paths: PackedStringArray) -> void:
	# CONTEXT_SLOT_SCRIPT_EDITOR_CODE では paths[0] に CodeEdit のノードパスが入る
	if paths.is_empty():
		return
	var code_edit: CodeEdit = Engine.get_main_loop().root.get_node_or_null(paths[0]) as CodeEdit
	if code_edit == null or not code_edit.has_selection():
		return
	var icon: Texture2D = EditorInterface.get_editor_theme().get_icon("ActionCopy", "EditorIcons")
	add_context_menu_item(MENU_LABEL, _on_copy_with_scope, icon)


func _on_copy_with_scope(target: Object) -> void:
	var code_edit: CodeEdit = target as CodeEdit
	if code_edit == null:
		return

	var file_path: String = _get_current_file_path()
	var blocks: PackedStringArray = PackedStringArray()

	# マルチカーソル選択にも対応（キャレットごとに1ブロック）
	for caret: int in code_edit.get_caret_count():
		if not code_edit.has_selection(caret):
			continue
		var from_line: int = code_edit.get_selection_from_line(caret)
		var to_line: int = code_edit.get_selection_to_line(caret)
		var to_column: int = code_edit.get_selection_to_column(caret)
		# 次の行の先頭（列0）で選択が終わっている場合、その行は範囲に含めない
		if to_line > from_line and to_column == 0:
			to_line -= 1

		var text: String = code_edit.get_selected_text(caret)
		# 末尾の改行は除去（コードブロックの閉じ記号を次行に置くため）
		while text.ends_with("\n"):
			text = text.substr(0, text.length() - 1)

		blocks.append(_format_block(file_path, from_line + 1, to_line + 1, text))

	if blocks.is_empty():
		return

	DisplayServer.clipboard_set("\n\n".join(blocks) + "\n")
	print_rich("[color=gray][Scope Copy] Copied %d block(s) from %s[/color]" % [blocks.size(), file_path])


func _format_block(file_path: String, start_line: int, end_line: int, text: String) -> String:
	var fence: String = "```"
	# コード内に ``` が含まれる場合はフェンスを長くする
	while text.contains(fence):
		fence += "`"
	var header: String = "%s:%d-%d" % [file_path, start_line, end_line]
	return "%s\n%s\n%s\n%s" % [header, fence, text, fence]


func _get_current_file_path() -> String:
	var script_editor: ScriptEditor = EditorInterface.get_script_editor()
	var script: Script = script_editor.get_current_script()
	if script != null and not script.resource_path.is_empty():
		return script.resource_path
	return "(unsaved)"
