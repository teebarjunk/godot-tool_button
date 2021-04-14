extends EditorInspectorPlugin

var InspectorToolButton = preload("res://addons/tool_button/TB_Button.gd")
var pluginref

func _init(p):
	pluginref = p
	
func can_handle(object):
	return object.has_method("_get_tool_buttons")

func parse_begin(object):
	var methods
	if object is Resource:
		methods = object.get_script()._get_tool_buttons()
	else:
		methods = object._get_tool_buttons()
    
	if methods:
		for method in methods:
			add_custom_control(InspectorToolButton.new(object, method, pluginref))
