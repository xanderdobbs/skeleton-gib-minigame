extends KinematicBody2D

const SPEED := 1000.0
var velocity := Vector2()
var energy := 0.01


func _ready():
    set_process(false)

func _process(delta):
    var collision := move_and_collide(velocity * SPEED * energy * delta)
    energy = move_toward(energy, 0.0, delta)
    if collision:
        if collision.collider.has_method("take_hit"):
            collision.collider.take_hit(self,collision)
            add_collision_exception_with(collision.collider)
            velocity = velocity.linear_interpolate(collision.normal, .2 * energy)
#            energy -= .05
    if energy <= 0 or is_zero_approx(energy):
        set_process(false)
        $CollisionShape2D.disabled = true
