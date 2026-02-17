extends CanvasLayer

@onready var titleScreen = $titleScreen
@onready var title = $title
@onready var animation_player = $AnimationPlayer
@onready var scoreNode = $score

signal transitionFinished

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	titleScreen.visible = false
	title.visible = false 
	scoreNode.visible = false 
	animation_player.animation_finished.connect(_on_animation_finished)

func transition():
	titleScreen.visible = true 
	title.visible = true 
	scoreNode.visible = true
	Score.incrementScore()
	scoreNode.text = "[font_size=48][color=#Ff0000]Score: "  + str(Score.totalScore) + "[/color]"
	animation_player.play("fade_to_black")
	
func _on_animation_finished(anim_name):
	if anim_name == "fade_to_black":
		transitionFinished.emit()
		animation_player.play("fade_to_normal")
	elif anim_name == "fade_to_normal":
		Score.resetStage()
		titleScreen.visible = false
		title.visible = false 
		scoreNode.visible = false 
