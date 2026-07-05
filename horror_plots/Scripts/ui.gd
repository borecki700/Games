extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.stars_updated.connect(update_star_score)
	update_star_score(GameManager.star_collcted)


func update_star_score(amount):
	$stars_scored.text = str(amount) + " /8"
