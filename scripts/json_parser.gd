## Parses JSON files into dictionaries.
class_name JSONParser extends RefCounted

## Retrieve dictionary from JSON file
static func parse(filepath:String) -> Dictionary:
	if FileAccess.file_exists(filepath):
		var file:FileAccess = FileAccess.open(filepath, FileAccess.READ)
		if file:
			return JSON.parse_string(file.get_as_text())
		else:
			push_error("Failed to open file '"+filepath+"'")
	else:
		push_error("File '"+filepath+"' doesn't exist")
	
	return {} # no data retrieved
