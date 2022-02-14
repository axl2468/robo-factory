extends Area2D

export var bullet_s = 1.5
var direction = Vector2()


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _physics_process(_delta):
	if direction != Vector2():
		var velocity = direction * bullet_s
		global_position += velocity

func set_direction(direction: Vector2):
	self.direction = direction
	rotation += direction.angle()


func _on_Area2D_body_entered(body):
	if body.has_method("handle_hit_player"):
		body.handle_hit_player(20) #param: damage done
		queue_free()
	elif !body.has_method("handle_hit_enemy"):
		queue_free()
	
