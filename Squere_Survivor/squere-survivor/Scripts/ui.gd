extends CanvasLayer

@onready var score_label: Label = $ScoreLabel

func _process(delta: float) -> void:
	# Co klatkę aktualizujemy tekst napisu wartością z globalnego skryptu
	score_label.text = "Kills: " + str(Global.score)
