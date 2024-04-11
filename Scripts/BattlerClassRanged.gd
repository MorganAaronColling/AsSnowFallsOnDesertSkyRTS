extends 'res://Scripts/BattlerClass.gd'

@export var arrow : PackedScene
@onready var arrowEmitter  = $UnitPivot/ArrowEmitter

func _ready():
	update_stats()
	selectionTween = get_selection_tween()
	
func _physics_process(delta):
	match state:
		IDLE:
			if is_instance_valid(attack_target) and attack_target.state != DEAD:
				state = MOVING
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
				move_to_position(get_circle_position(attack_target.global_position, get_radius_range_circle_position()), delta)
				set_facing_direction()
			else:
				state = IDLE
	apply_friction(delta)

func deal_damage():
	if BattlerAnimation.animation == 'attack':
		if BattlerAnimation.frame == 3 and attackArea.monitoring:
			for area in attackArea.get_overlapping_areas():
				var parent = area.get_parent()
				if area.is_in_group('Unit') and parent != self and parent.tribe != tribe and parent == attack_target:
					spawn_arrow(parent)
					if !cleave:
						attackArea.monitoring = false
						break
		else:
			pass
			
func take_damage(damage, ranged):
	if state != DEAD and state != HURT and state != BLOCK:
		BloodSplatter.emitting = true
		health -= damage
		if selected:
			GUIHealth.text = str(health) + '/' + str(max_health)
		if health > 0:
			state = HURT
			BattlerAnimation.play("hurt")
		else:
			if selected:
				GUIPortraitBackground.play('break')
			attackArea.monitoring = false
			state = DEAD
			BattlerAnimation.play("death")
			
func spawn_arrow(target):
	var arrow_offset = Vector2(0, -10)
	var arrow_direction = (target.global_position - arrowEmitter.global_position) + arrow_offset
	var a = arrow.instantiate()
	a.transform = arrowEmitter.transform
	a.initial_direction = arrow_direction.normalized()
	a.tribe = tribe
	a.attack_target = target
	a.damage = attack_damage
	add_child(a)
