extends EditorInspectorPlugin

var InspectorToolButton = preload("res://addons/tool_button/TB_Button.gd")
var pluginref

var cache_methods:Dictionary = {}
var cache_selected:Dictionary = {}

func _init(p):
	pluginref = p

func _can_handle(object):
	cache_methods[object] = _collect_methods(object)
	return cache_methods[object] or object.has_method("_get_tool_buttons")

# buttons at bottom of inspector
var object_category_cache = []
func _parse_category(object, category):
	var obj_script = object.get_script()
	var has_exports = "@export" in obj_script.source_code
	var attached_script_category = ""
	if obj_script and has_exports:
		attached_script_category = obj_script.resource_path.get_file()
		object_category_cache.append(attached_script_category)

	if not attached_script_category.is_empty() \
		and category == attached_script_category :
		if cache_methods[object]:
				for method in cache_methods[object]:
					add_custom_control(InspectorToolButton.new(object, {
						tint=Color.GREEN_YELLOW,
						call=method,
						print=true,
						update_filesystem=true
					}, pluginref))
	elif attached_script_category not in object_category_cache:
		prints(category, attached_script_category)
		match category:
			"Node", "Resource":
				if cache_methods[object]:
					for method in cache_methods[object]:
						add_custom_control(InspectorToolButton.new(object, {
							tint=Color.GREEN_YELLOW,
							call=method,
							print=true,
							update_filesystem=true
						}, pluginref))

# buttons defined in _get_tool_buttons show at the top
func _parse_begin(object):
	if object.has_method("_get_tool_buttons"):

		var methods
		if object is Resource:
			methods = object.get_script()._get_tool_buttons()
		else:
			methods = object._get_tool_buttons()

		if methods:
			for method in methods:
				add_custom_control(InspectorToolButton.new(object, method, pluginref))

func _allow_method(name:String) -> bool:
	return not name.begins_with("_")\
		and not name.begins_with("set_")\
		and not name.begins_with("@")

func _collect_methods(object:Object) -> Array:
	var script = object.get_script()
	if not script or not script.is_tool():
		return []

	var default_methods = []

	# ignore methods of parent
	if object is Resource:
		for m in ClassDB.class_get_method_list(object.get_script().get_class()):
			default_methods.append(m.name)
	else:
		for m in ClassDB.class_get_method_list(object.get_class()):
			default_methods.append(m.name)

	var methods = []
	for m in object.get_method_list():
		if not m.name in default_methods:
			if _allow_method(m.name) and len(m.args) == len(m.default_args):
				methods.append(m.name)

	return methods
