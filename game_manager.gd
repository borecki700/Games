extends Node

signal all_star_collcted
signal stars_updated(new_amount)

var star_collcted = 0:
	set(value):
		star_collcted = value
		stars_updated.emit(star_collcted)
		if star_collcted >= 8:
			all_star_collcted.emit()
