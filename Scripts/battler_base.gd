extends CharacterBody2D

@onready var BattlerAnimation = $UnitPivot/AnimatedSprite2D
@onready var BattlerAnimationShadow = $AnimatedSpriteShadow2D
@onready var UnitPivot = $UnitPivot
@onready var SurroundTimer = $SurroundTimer
@onready var attackArea = $UnitPivot/AttackArea
@onready var attackDelayTimer = $AttackDelayTimer

var max_speed: int= 200
var acceleration: int = 70
var friction: float = max_speed / acceleration
var input_position: Vector2
var surround_position: Vector2
var selected: bool
var selectionTween
@export var tribe: String
var attack_target
var attack_damage = 5
var max_health = 15
var health = max_health
# ENUM
enum {
	MOVING,
	ATTACK,
	IDLE,
	DEAD,
	SURROUND,
	HURT,
	BLOCK
}

# STATE
var state = IDLE

func _ready():
	selectionTween = get_selection_tween()
	if tribe == 'AI':
		BattlerAnimation.sprite_frames = load("res://SpriteFrames/OrcSpriteFrames.tres")
		BattlerAnimationShadow.sprite_frames = load("res://SpriteFrames/OrcSpriteFrames.tres")
	else:
		BattlerAnimation.sprite_frames = load("res://SpriteFrames/KnightSpriteFrames.tres")
		BattlerAnimationShadow.sprite_frames = load("res://SpriteFrames/KnightSpriteFrames.tres")
	

func _process(delta):
	pass
	
func _physics_process(delta):
	match state:
		IDLE:
			if is_instance_valid(attack_target):
				state = MOVING
			else:
				var unitList = get_parent().get_parent().unitList
				update_attack_target()
		ATTACK:
			deal_damage()
		SURROUND:
			#update_attack_target()
			if is_instance_valid(attack_target):
				move_to_position(get_circle_position(attack_target.global_position), delta)
				set_facing_direction()
			else:
				state = IDLE
		HURT:
			pass
		BLOCK:
			pass
		DEAD:
			pass
		MOVING:
			#update_attack_target()
			if is_instance_valid(attack_target):
				move_to_position(attack_target.global_position, delta)
				set_facing_direction()
			else:
				state = IDLE
	apply_friction(delta)
		
func _on_animated_sprite_2d_animation_changed():
	if BattlerAnimation and BattlerAnimationShadow:
		BattlerAnimationShadow.play(BattlerAnimation.animation)
	
func set_facing_direction() -> void:
	if attack_target.global_position.x < global_position.x:
		UnitPivot.scale.x = -1
		BattlerAnimationShadow.flip_h = true
	elif attack_target.global_position.x > global_position.x:
		UnitPivot.scale.x = 1
		BattlerAnimationShadow.flip_h = false
	
func move_to_position(target_position, delta):
	if velocity.length() > 0:
		BattlerAnimation.play('walk')
	else:
		BattlerAnimation.play('idle')
	var direction = (target_position - global_position).normalized()
	velocity += direction * acceleration * delta
	avoid_obstacles()
	move_and_slide()
	
func apply_friction(delta: float) -> void:
	velocity -= velocity * friction * delta
	
func set_selected(is_selected):
	if tribe == 'Player':
		selected = is_selected
		if selected:
			selectionTween.play()
		else:
			selectionTween.pause()
			BattlerAnimation.modulate = Color(1, 1, 1, 1)

func _on_selection_area_input_event(viewport, event, shape_idx):
	if event.is_action_pressed('left_click'):
		if !selected:
			set_selected(true)
		else:
			set_selected(false)
		
func get_selection_tween():
	var tween = create_tween().set_loops()
	tween.tween_property(BattlerAnimation, "modulate", Color(1.5, 1.5, 1.2, 0.5), 0.5)
	tween.tween_interval(0.1)
	tween.tween_property(BattlerAnimation, "modulate", Color(1.5, 1.5, 1.2, 1), 0.5)
	tween.pause()
	return tween
	
func get_enemy_target(unitList):
	var target_list
	if tribe == 'AI':
		target_list = unitList[0]
	else:
		target_list = unitList[1]
	return get_closest_target(target_list)
	
func get_closest_target(target_list):
	var closest_target
	var closest_target_distance = 99999
	for target in target_list:
		if is_instance_valid(target) and target.state != DEAD:
			var target_distance = (target.global_position - global_position).length()
			if target_distance > closest_target_distance:
				pass
			else:
				closest_target = target
				closest_target_distance = target_distance
	return closest_target

func _on_attack_area_area_entered(area):
	var parent = area.get_parent()
	if area.is_in_group('Unit') and parent != self and parent.tribe != tribe and state != SURROUND:
		attackDelayTimer.start(randf_range(0, 0.25))
		
func _on_animated_sprite_2d_animation_finished():
	if BattlerAnimation.animation == 'attack':
		state = SURROUND
		SurroundTimer.start(randf_range(3, 4))
		attackArea.monitoring = false
	if BattlerAnimation.animation == 'hurt':
		await get_tree().create_timer(0.4).timeout
		state = SURROUND
		SurroundTimer.start(randf_range(3, 4))
		attackArea.monitoring = false
	if BattlerAnimation.animation == 'blocking':
		await get_tree().create_timer(0.3).timeout
		state = SURROUND
		SurroundTimer.start(randf_range(1, 2))
	if BattlerAnimation.animation == 'death':
		var tween = create_tween()
		tween.tween_property(self, "modulate", Color(0, 0, 0, 0), 0.2)
		await get_tree().create_timer(0.2).timeout
		queue_free()
		
func get_circle_position(circle_centre):
	var angle
	if circle_centre.x < global_position.x:
		angle = (randi_range(-4, 4) * (PI / 8));
	else:
		angle = (randi_range(4, 12) * (PI / 8));
	var radius = randi_range(60, 80)
	var x = circle_centre.x + cos(angle) * radius;
	var y = circle_centre.y + sin(angle) * radius;
	return Vector2(x, y)

func _on_surround_timer_timeout():
	if is_instance_valid(attack_target) and state != DEAD and state != HURT:
		update_attack_target()
		state = MOVING
		attackArea.monitoring = true

func deal_damage():
	if BattlerAnimation.animation == 'attack':
		if BattlerAnimation.frame == 3 and attackArea.monitoring:
			for area in attackArea.get_overlapping_areas():
				var parent = area.get_parent()
				if area.is_in_group('Unit') and parent != self and parent.tribe != tribe:
					parent.take_damage(attack_damage)	
					break
		else:
			pass
			
func take_damage(damage):
	if state != DEAD and state != HURT and state != BLOCK:
		if randf() < 0.15:
			state = BLOCK
			BattlerAnimation.play("blocking")
		else:
			health -= damage
			if health > 0:
				state = HURT
				BattlerAnimation.play("hurt")
			else:
				attackArea.monitoring = false
				state = DEAD
				BattlerAnimation.play("death")

func _on_attack_delay_timer_timeout():
	if is_instance_valid(attack_target) and state != DEAD and state != HURT:
		update_attack_target()
		state = ATTACK
		BattlerAnimation.play("attack")
		
func update_attack_target():
	var unitList = get_parent().get_parent().unitList
	if tribe == 'AI':
		unitList = unitList[0]
	else:
		unitList = unitList[1]
	if unitList.is_empty():
		BattlerAnimation.play("idle")
	else:
		attack_target = get_closest_target(unitList)
	
func avoid_obstacles():
	var rayCast = $RayCast2D
	# Iterate through 8 directions (adjust angles for your needs)
	for angle in [0, PI/4, PI/2, 3*PI/4, PI, 5*PI/4, 3*PI/2, 7*PI/4]:
		# Cast ray in the direction
		rayCast.target_position = Vector2.from_angle(angle) * 30
		rayCast.force_raycast_update()
		# Check for collision
		if rayCast.is_colliding():
			# Obstacle detected, adjust velocity to avoid
			velocity = (velocity + Vector2.from_angle(angle).orthogonal()).normalized() * velocity.length()
			break  # Only consider closest obstacle
