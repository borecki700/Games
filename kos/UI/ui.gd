extends CanvasLayer


@onready var score_label := $ScoreLabel
@onready var health_bar := $HealthBar

var score := 0

func _ready():
	score_label.text = "Score: 0"
	health_bar.value = 3

func add_points(amount):
	score += amount
	score_label.text = "Score: %d" % score

func update_health_bar(value: int):
	health_bar.value = value
