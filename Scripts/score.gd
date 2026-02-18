extends Node

var currentScore = 0
var totalScore = 0
var kills = 0 
var timeScore = 1000

var elapsed_time: float = 0.0
		
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	elapsed_time += delta
	
func incrementScore() -> void:
	currentScore += calculateScore()
	totalScore += currentScore
	
func incrementKills(change) -> void:
	kills += change
	
func finalScore() -> int:
	return totalScore

func reset_score() -> void:
	elapsed_time = 0
	currentScore = 0
	totalScore = 0
	kills = 0
	
func resetStage():
	elapsed_time = 0
	currentScore = 0 
	kills = 0 
	
func calculateScore() -> int:
	return kills * 1000 + (timeScore - elapsed_time)
