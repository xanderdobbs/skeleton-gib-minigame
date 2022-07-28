extends KinematicBody2D

const SPEED := 1.0
var stance := 0.0
var packed_enemy := preload("res://Skeleton.tscn")


func _ready():
    pass

func _process(delta):
    $ProgressBar.value = stance
    
    var velocity := Vector2()
    if Input.is_action_pressed("ui_up"):
        velocity.y -= delta
    if Input.is_action_pressed("ui_down"):
        velocity.y += delta
    if Input.is_action_pressed("ui_left"):
        velocity.x -= delta
    if Input.is_action_pressed("ui_right"):
        velocity.x += delta
    
    if Input.is_action_just_released("ui_home"):
        spawn_enemy()
    
    if Input.is_action_pressed("mouse_left"):
        charge(delta)
    if Input.is_action_just_released("mouse_left"):
        shoot()
    
    if Input.is_action_just_released("ui_cancel"):
        get_tree().reload_current_scene()
    
    translate(velocity.normalized() * SPEED)

    
func shoot():
    
    var aim := position.direction_to(get_global_mouse_position())
    var bullet = $Bullet.duplicate()
    
    bullet.velocity = aim
    bullet.energy = stance
    get_parent().add_child(bullet)
    bullet.transform = get_global_transform()
    bullet.set_process(true)
    
    stance = 0.0
    
func spawn_enemy():
    var enemy := packed_enemy.instance()
    enemy.exploded = false
    enemy.position = Vector2(160, 90)
    get_parent().add_child(enemy)
    
func charge(delta):
    stance += delta / 2
    stance = clamp(stance, 0.0, 1.0)
    
    
    
    
