extends Control

var indicators: Dictionary = {
	"full": preload("res://UI/HeartIndicator/full_heart_indicator.tscn").instantiate(),
	"half": preload("res://UI/HeartIndicator/half_heart_indicator.tscn").instantiate(),
	"empty": preload("res://UI/HeartIndicator/no_heart_indicator.tscn").instantiate()
}

@onready var grid_container = $GridContainer
@onready var animation_player = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	GameStats.on_remove_health.connect(remove)
	GameStats.on_add_health.connect(add)
	GameStats.on_reset_health.connect(reset)
	reset()

func reset():
	render()	
	
func render():
	for child in grid_container.get_children():
		child.queue_free()
		
	for count in range(GameStats.TOTAL_HEALTH):
		var duplicate_node: Node
		if (count < GameStats.health):
			duplicate_node = indicators.full.duplicate()
		else:
			duplicate_node = indicators.empty.duplicate()
			
		grid_container.add_child(duplicate_node)


func add():
	#animation_player.play("add")
	render()

func remove():
	#animation_player.play("remove")
	render()
