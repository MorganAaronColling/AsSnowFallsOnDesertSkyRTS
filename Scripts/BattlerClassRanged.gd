extends 'res://Scripts/BattlerClass.gd'

@export var arrow : PackedScene
@onready var arrowEmitter  = $UnitPivot/ArrowEmitter
	
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
					move_to_position(get_circle_position(attack_target.global_position, get_radius_range_circle_position()), delta)
					set_facing_direction()
				else:
					state = IDLE
		apply_friction(delta)
	elif dragged:
		global_position = get_global_mouse_position()

func deal_damage():
	if BattlerAnimation.animation == 'attack' and !attacked:
		if BattlerAnimation.frame == 3 and attackArea.monitoring:
			var overlapping_areas = attackArea.get_overlapping_areas()
			if is_instance_valid(attack_target) and overlapping_areas.has(attack_target.attackArea):
				spawn_arrow(attack_target)
			else:
				for area in overlapping_areas:
					var parent = area.get_parent()
					if area.is_in_group('Unit') and parent != self and parent.tribe != tribe:
						spawn_arrow(parent)
						if !cleave:
							attackArea.monitoring = false
							break
			
func spawn_arrow(target):
	attacked = true
	if arrowBurst:
		for i in 3:
			if is_instance_valid(target):
				var arrow_offset = Vector2(0, randi_range(-5, -15))
				var arrow_direction = (target.global_position - arrowEmitter.global_position) + arrow_offset
				var a = arrow.instantiate()
				a.transform = arrowEmitter.transform
				a.initial_direction = arrow_direction.normalized()
				a.tribe = tribe
				a.attack_target = target
				a.damage = attack_damage
				add_child(a)
				await get_tree().create_timer(0.1).timeout
	else:
		var arrow_offset = Vector2(0, -10)
		var arrow_direction = (target.global_position - arrowEmitter.global_position) + arrow_offset
		var a = arrow.instantiate()
		a.transform = arrowEmitter.transform
		a.initial_direction = arrow_direction.normalized()
		a.tribe = tribe
		a.attack_target = target
		a.damage = attack_damage
		add_child(a)
