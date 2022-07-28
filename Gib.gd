class_name Gib
extends Sprite

const SPEED  := 60.0
var velocity := Vector2()
var spin     := 0.0


func _ready():
    z_index = -1


func _process(delta):
    translate(velocity * SPEED * delta)
    rotate(spin * SPEED * delta)
    velocity = velocity.linear_interpolate(Vector2(), 0.5)
    spin = lerp(spin, 0.0, 0.5)
    
    if is_zero_approx(velocity.length() + spin):
        set_process(false)
