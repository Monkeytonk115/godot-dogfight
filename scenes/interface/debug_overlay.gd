extends MarginContainer

var _visible = true

var mesh

# https://kidscancode.org/godot_recipes/ui/debug_overlay/
# A class to contain each of the Properties we want to display
# in the debug overlay
class Property:
	var number_format = "%4.2f"
	var object # The object we are getting the property of
	var property # a nodepath of the property e.g. "tranform:origin"
	var label_ref # a reference to the label that we need to update the text of
	var display # the display format "", "length", or "round"
	
	func _init(_object,_property,_label,_display):
		object = _object
		property = _property
		label_ref = _label
		display = _display
		
	func update_label():
		#print(object.name, property)
		var s = "[" + object.name + "/" + property + "] "
		var p = object.get_indexed(property)
		match display:
			"":
				s += str(p)
			"length":
				#print(s)
				s += number_format % p.length()
			"round":
				match typeof(p):
					TYPE_INT, TYPE_FLOAT:
						s += number_format % p
					TYPE_VECTOR2, TYPE_VECTOR3:
						s += "(%4.2f, %4.2f, %4.2f)" % [p.x, p.y, p.z]
		label_ref.text = s

# A list of all the Property objects we are currently displaying
var props = []

func add_property(object, property, display):
	var label = Label.new()
	label.add_theme_color_override("font_color", Color.LIME)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	$PropertyInspector.add_child(label)
	props.append(Property.new(object, property, label, display))


func remove_property(object, property):
	for prop in props:
		if prop.object == object and prop.property == property:
			props.erase(prop)


func _process(_delta):
	if not visible:
		return
	for prop in props:
		prop.update_label()
	queue_redraw()


func _input(event):
	if event is InputEventKey:
		if event.keycode == KEY_F3 and event.pressed and not event.echo:
			_visible = not _visible
			if _visible:
				show()
			else:
				hide()

func _ready():
	mesh = $MeshInstance3D.mesh
