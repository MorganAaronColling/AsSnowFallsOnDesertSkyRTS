extends CharacterBody2D

# UnitStats Resource
var unitStats = preload('res://Resources/UnitStats.tres')

# Blood
var bloodEffect = preload("res://Prefabs/blood_effect.tscn") 

# Nodes
@onready var BattlerAnimation = $UnitPivot/AnimatedSprite2D
@onready var BattlerAnimationShadow = $AnimatedSpriteShadow2D
@onready var UnitPivot = $UnitPivot
@onready var SurroundTimer = $SurroundTimer
@onready var attackArea = $UnitPivot/AttackArea
@onready var attackDelayTimer = $AttackDelayTimer
@onready var healthBar = $HealthBarControl/HealthBar
@onready var GUIPortraitAnimation = get_node('../../GUI/SelectedUnit')
@onready var GUIHealth = get_node('../../GUI/Health')
@onready var GUIPortraitBackground = get_node('../../GUI/Portrait')
@onready var Game = get_node('../../')

# Stats
var drag_acceleration: int = 1000
var max_speed: int
var acceleration: int
var friction: float
var attack_damage: int
var max_health: int
var hurt_delay = 0.2
var block_delay = 0.1
var surround_timer_delay_melee = randf_range(0.25, 0.5)
var surround_timer_delay_ranged = randf_range(0.5, 0.75)
var health
var race

# Misc
@export var tribe: String
var input_position: Vector2
var surround_position: Vector2
var selected: bool
var selectionTween: Tween
var pregameTween: Tween
var attack_target: CharacterBody2D
var dragged: bool = false
var attacked: bool = false
var starter_unit: bool = true

# Abilities
var cleave: bool = false
var sturdy: bool = false
var isRangedUnit: bool = false
var lifesteal: bool = false
var arrowBurst: bool = false

# ENUM
enum {
	MOVING,
	ATTACK,
	IDLE,
	DEAD,
	SURROUND,
	HURT,
	BLOCK,
	CONTROLLED
	
}

# STATE
var state = IDLE

func update_stats():
	var data = unitStats.data[name.split('-', true)[0]]
	# BASE STATS
	race = data.race
	max_speed = data.max_speed
	acceleration = data.acceleration
	friction = data.friction
	attack_damage = data.attack_damage
	max_health = data.max_health
	isRangedUnit = data.ranged
	if !isRangedUnit:
		cleave = data.cleave
		lifesteal = data.lifesteal
		sturdy = data.sturdy
	else:
		arrowBurst = data.arrowBurst
	health = max_health
	update_health_bar()
	
func _ready():
	update_stats()
	selectionTween = get_selection_tween()
	pregameTween = get_pre_start_tween()
	if tribe == 'AI':
		pregameTween.play()
	else:
		if !starter_unit:
			Game.update_bonuses()
	
	
func _physics_process(delta):
	if Game.started:
		match state:
			IDLE:
				if is_instance_valid(attack_target) and attack_target.state != DEAD:
					enter_surround_state()
				else:
					var unitList = get_parent().get_parent().unitList
					update_attack_target()
			ATTACK:
				deal_damage()
			SURROUND:
				update_attack_target()
				if is_instance_valid(attack_target) and attack_target.state != DEAD:
					move_to_position(get_circle_position(attack_target.global_position, get_radius_range_circle_position()), delta)
					set_facing_direction()
				else:
					state = IDLE
			HURT:
				pass
			BLOCK:
				pass
			DEAD:
				pass
			CONTROLLED:
				pass
			MOVING:
				update_attack_target()
				if is_instance_valid(attack_target) and attack_target.state != DEAD:
					move_to_position(attack_target.global_position, delta)
					set_facing_direction()
				else:
					state = IDLE
		apply_friction(delta)
	elif dragged:
		global_position = get_global_mouse_position()
	
func get_radius_range_circle_position():
	if self.is_in_group('Ranged'):
		return randi_range(90, 110)
	else:
		if is_instance_valid(attack_target) and attack_target.is_in_group('Ranged'):
			return randi_range(20, 40)
		else:
			return randi_range(20, 80)
		
func _on_animated_sprite_2d_animation_changed():
	if BattlerAnimation and BattlerAnimationShadow:
		BattlerAnimationShadow.play(BattlerAnimation.animation)
	if selected:
		GUIPortraitAnimation.play(BattlerAnimation.animation)
	
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
	selected = is_selected
	if selected:
		selectionTween.play()
		GUIPortraitAnimation.visible = true
		GUIPortraitAnimation.sprite_frames = BattlerAnimation.sprite_frames
		GUIPortraitAnimation.play(BattlerAnimation.animation)
		GUIHealth.text = str(health) + '/' + str(max_health)
		GUIHealth.visible = true
		GUIPortraitBackground.play('default')
	else:
		GUIPortraitAnimation.visible = false
		GUIHealth.visible = false
		selectionTween.pause()
		BattlerAnimation.modulate = Color(1, 1, 1, 1)

func _on_selection_area_input_event(viewport, event, shape_idx):
	if event.is_action_pressed('left_click'):
		if !selected:
			set_selected(true)
		else:
			set_selected(false)
	elif event.is_action_pressed('right_click') and !Game.started and tribe == 'Player':
		Game.update_dragged(self, true)
	elif event.is_action_released("right_click") and !Game.started and tribe == 'Player':
		Game.update_dragged(self, false)
		
func set_dragged(is_dragged):
	dragged = is_dragged
	if dragged:
		BattlerAnimation.play('fall')
	else:
		BattlerAnimation.play('idle')
		
func get_selection_tween():
	var tween = create_tween().set_loops()
	tween.tween_property(BattlerAnimation, "modulate", Color(1.5, 1.5, 1.2, 0.5), 0.5)
	tween.tween_interval(0.1)
	tween.tween_property(BattlerAnimation, "modulate", Color(1.5, 1.5, 1.2, 1), 0.5)
	tween.pause()
	return tween
	
func get_pre_start_tween():
	var tween = create_tween().set_loops()
	tween.tween_property(BattlerAnimation, "modulate", Color(0.8, 0.8, 0.8, 0.5), 0.5)
	tween.tween_interval(0.1)
	tween.tween_property(BattlerAnimation, "modulate", Color(0.8, 0.8, 0.8, 1), 0.5)
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
	if area.is_in_group('Unit') and parent != self and parent.tribe != tribe and state != SURROUND and Game.started:
		attackDelayTimer.start(randf_range(0, 0.25))
		
func _on_animated_sprite_2d_animation_finished():
	if BattlerAnimation.animation == 'attack':
		attacked = false
		enter_surround_state()
		attackArea.monitoring = false
	if BattlerAnimation.animation == 'hurt':
		await get_tree().create_timer(hurt_delay).timeout
		enter_surround_state()
		attackArea.monitoring = false
	if BattlerAnimation.animation == 'blocking':
		await get_tree().create_timer(block_delay).timeout
		enter_surround_state()
	if BattlerAnimation.animation == 'death':
		var tween = create_tween()
		tween.tween_property(self, "modulate", Color(0, 0, 0, 0), 0.2)
		await get_tree().create_timer(0.2).timeout
		if tribe != 'Player':
			queue_free()
		
func enter_surround_state():
	attackArea.monitoring = false
	state = SURROUND
	if is_instance_valid(attack_target) and attack_target.is_in_group('Ranged'):
		SurroundTimer.start(surround_timer_delay_ranged)
	else:
		SurroundTimer.start(surround_timer_delay_melee)
		
func get_circle_position(circle_centre, radius):
	var angle
	if circle_centre.x < global_position.x:
		angle = (randi_range(-3, 3) * (PI / 8));
	else:
		angle = (randi_range(3, 11) * (PI / 8));
	var x = circle_centre.x + cos(angle) * radius;
	var y = circle_centre.y + sin(angle) * radius;
	return Vector2(x, y)
		
func _on_surround_timer_timeout():
	if is_instance_valid(attack_target) and state != DEAD and state != HURT:
		update_attack_target()
		state = MOVING
		attackArea.monitoring = true

func deal_damage():
	if BattlerAnimation.animation == 'attack' and !attacked:
		if BattlerAnimation.frame == 3 and attackArea.monitoring:
			for area in attackArea.get_overlapping_areas():
				var parent = area.get_parent()
				if area.is_in_group('Unit') and parent != self and parent.tribe != tribe:
					parent.take_damage(attack_damage, false)
					if !cleave:
						attacked = true
						break
					if lifesteal:
						heal(attack_damage / 2)
			attacked = true
		else:
			pass
			
func take_damage(damage, ranged):
	var chance = randf()
	if state != DEAD and state != BLOCK and !ranged:
		if chance < 0.25 and !isRangedUnit:
			state = BLOCK
			BattlerAnimation.play("blocking")
		else:
			health -= damage
			show_blood_effect()
			update_health_bar()
			if selected:
				GUIHealth.text = str(health) + '/' + str(max_health)
			if health > 0:
				if !sturdy:
					state = HURT
					BattlerAnimation.play("hurt")
			else:
				if selected:
					GUIPortraitBackground.play('break')
				attackArea.monitoring = false
				state = DEAD
				BattlerAnimation.play("death")
	elif state != DEAD and state != BLOCK and ranged:
		if chance < 0.20:
			pass
		else:
			health -= damage
			show_blood_effect()
			update_health_bar()
			if selected:
				GUIHealth.text = str(health) + '/' + str(max_health)
			if health > 0:
				if !sturdy:
					state = HURT
					BattlerAnimation.play("hurt")
			else:
				if selected:
					GUIPortraitBackground.play('break')
				attackArea.monitoring = false
				state = DEAD
				BattlerAnimation.play("death")
		
func _on_attack_delay_timer_timeout():
	if is_instance_valid(attack_target) and attack_target.state != DEAD and state != DEAD and state != HURT:
		update_attack_target()
		state = ATTACK
		BattlerAnimation.play("attack")
		
func update_attack_target():
	var unitList = get_parent().get_parent().unitList
	if tribe == 'AI':
		unitList = unitList[0]
	else:
		unitList = unitList[1]
	if unitList.is_empty() or (unitList.size() == 1 and unitList.has(attack_target) and attack_target.state == DEAD):
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
			
func reset_health():
	health = max_health
	update_health_bar()
	if selected:
		GUIHealth.text = str(health) + '/' + str(max_health)
		
func heal(heal_amount):
	if health < max_health:
		health += heal_amount
		if health > max_health:
			health = max_health
		
func update_health_bar():
	healthBar.max_value = max_health
	healthBar.value = health
	if selected:
		GUIHealth.text = str(health) + '/' + str(max_health)
		
func show_blood_effect():
	var b_effect = bloodEffect.instantiate()
	b_effect.emitting = true
	add_child(b_effect)
	UnitPivot.modulate = Color(0.984, 0, 0)
	await get_tree().create_timer(0.1).timeout
	UnitPivot.modulate = Color(1, 1, 1)
	

