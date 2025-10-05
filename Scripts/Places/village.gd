extends Place
class_name Village


func _enter_tree():
	generateVillage();

func get_place_type() -> String:
	return "Village"

func generateVillage() -> void:
	generatePlace();
	pass
