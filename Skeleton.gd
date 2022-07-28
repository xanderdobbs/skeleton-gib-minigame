extends KinematicBody2D

var SPEED := 20.0
var sprites := []
var timer := 0.0
var velocity := Vector2()
var exploded := false
var health := 3
var pain := 1.0

onready var skull_sprite = find_node("Skull_Sprite", false, false)
onready var arm_r_sprite = find_node("Arm_Sprite_R", false, false)
onready var arm_l_sprite = find_node("Arm_Sprite_L", false, false)

func _ready():
    randomize()
    velocity = Vector2(rand_vector().normalized())
    for child in get_children():
        if child is Sprite:
            sprites.append(child)
    $AnimationPlayer.play("WalkCycle")


func _process(delta):
#    if pain:
#        pain -= delta
#        if pain <= 0:
#            pain = 0.0
#            modulate = Color.white
#        else:
#            modulate = Color(10,10,10,1)
#        return
        
        
    if not exploded:
        if position.x >= 320 or position.x <= 0:
            velocity.x = -velocity.x
        if position.y >= 180 or position.y <= 0:
            velocity.y = -velocity.y
        translate(velocity * SPEED * delta)


func take_hit(collider: KinematicBody2D, collision: KinematicCollision2D) -> void:
    if collider.energy >= .3:
        health -= 3
    else:
        health -= 1
    if health > 0:
        chip(collider, collision)
    else:
        explode(collider, collision)
    
func chip(collider, collision):
    rattle(1,3,4)
    var chipped_sprite : Sprite
    match collision.collider_shape.name:
        "Skull":
            chipped_sprite = skull_sprite
            collision.collider_shape.set_deferred("disabled", true)
        "Arm_R":
            chipped_sprite = arm_r_sprite
            collision.collider_shape.set_deferred("disabled", true)
        "Arm_L":
            chipped_sprite = arm_l_sprite
            collision.collider_shape.set_deferred("disabled", true)
        "Trunk", _:
            sprites.shuffle()
            if "Torso" in sprites[0].name or "Leg" in sprites[0].name:
                chip(collider, collision)
                return
            else:
                chipped_sprite = sprites[0]
    make_gib_from(chipped_sprite, collider)
    chipped_sprite.hide()       
    sprites.erase(chipped_sprite)

func explode(collider: KinematicBody2D, collision: KinematicCollision2D) -> void:
#    var copy := self.duplicate()
#    get_parent().add_child(copy)
    rattle(sprites.size()-2,1,2)
    exploded = true
    for sprite in sprites:
        make_gib_from(sprite, collider)
    $AnimationPlayer.stop()
    queue_free()


func rand_vector() -> Vector2:
    return Vector2(rand_range(-1.0, 1.0), rand_range(-1.0, 1.0))


func make_gib_from(sprite: Sprite, collider: KinematicBody2D):
    sprite.hide()
        
    var new_gib := Gib.new()
    new_gib.texture = sprite.texture
    
    var spread = (PI - collider.energy * PI)/4
    var vel: Vector2 = collider.velocity.rotated(rand_range(-spread,spread))
    vel = vel.normalized() * rand_range(0.0,collider.energy * 60.0)
    new_gib.velocity = vel
    
    new_gib.spin = randf() * collider.energy * 10.0
    
    get_parent().add_child(new_gib)
    new_gib.transform = get_global_transform()

func rattle(times: int, pitch_min: int, pitch_max: int):
    for _i in times:
        var sound = $Rattle.duplicate()
        sound.pitch_scale = rand_range(pitch_min,pitch_max)
        sound.play()
        sound.connect("finished",sound,"queue_free")
        get_parent().add_child(sound)
        sound.transform = get_global_transform()
