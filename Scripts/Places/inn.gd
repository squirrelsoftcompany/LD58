extends Place
class_name Inn


func _enter_tree():
	generateInn();
	
func get_place_type() -> String:
	return "Inn"
	
func generateInn() -> void:
	generatePlace();
	pass
