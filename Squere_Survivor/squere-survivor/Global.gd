extends Node

var score: int = 0
var harder: int = 0

func add_score(amount: int):
	score += amount
	harder += amount
	print("Aktualny wynik: ", score)
