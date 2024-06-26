extends CharacterBody3D

#プレイヤー
var Player = null
var target_position = Vector3.ZERO
#ノードの前方
var forward_direction = Vector3.ZERO
#重力
var gravity = Vector3.ZERO
var move_speed: float = 13.0
var distance: float = 999.0
var animation_tree = null
var state_machine = null
var anim_state = null
var EffecPos : Node3D = null
var attack_flag = false
var kick_area: Area3D = null
var player_enter_kick: bool = false
var player_skeleton: Skeleton3D = null
var player_script: CharacterBody3D = null
var self_skeleton: Skeleton3D = null
var body_enter: bool = false
var Flag00: bool = false
var animation_player: AnimationPlayer = null
var k_state = null
var guard_falg: bool = false
var can_parry_flag = false
var bar: ProgressBar = null
var Flag01 = true
var k_bar: ProgressBar = null
var WinText: Label = null
var audioplayer: AudioStreamPlayer3D = null
var PauseText: Label = null
#signal damage_enemy
# Get the gravity from the project settings to be synced with RigidBody nodes.
func _ready():
	gravity = Vector3.DOWN * ProjectSettings.get_setting("physics/3d/default_gravity")
	#プレイヤーの取得
	Player = get_node("../Koishi")
	animation_tree = get_node("reimu/Armature/AnimationTree")
	state_machine = animation_tree.get("parameters/playback")
	EffecPos = get_node("reimu/Armature/EffecPos")
	kick_area = get_node("reimu/Armature/Area3D")
	player_skeleton = get_node("../Koishi/koishi01godot/Armature/GeneralSkeleton")
	self_skeleton = get_node("reimu/Armature/GeneralSkeleton")
	var k_tree = get_node("../Koishi/koishi01godot/Armature/AnimationTree")
	bar = get_node("../Reimu_Life")
	k_bar = get_node("../Koishi_Life")
	WinText = get_node("../WinText")
	audioplayer = get_node("reimu/Armature/AudioStreamPlayer3D")
	PauseText = get_node("../PauseText")
	k_state = k_tree.get("parameters/playback")
	#animation_player = get_node("reimu/Armature/AnimationPlayer")
	kick_area.connect("body_entered", Callable(self, "_on_body_entered"))
	kick_area.connect("body_exited", Callable(self, "_on_Area_body_exited"))
	bar.value = 100
	#state_machine.travel("run")
func _physics_process(delta):
	anim_state = state_machine.get_current_node()
	var current_position = state_machine.get_current_play_position ()
	if bar.value <= 0:
		if anim_state != "death":
			state_machine.travel("death")
		if Flag01:
			WinText.text = "You Win"
			PauseText.text = "press r key retry. press q key quit."
			Flag01 = false
			
	if k_bar.value <= 0:
		if anim_state != "win":
			state_machine.travel("win")
		if Flag01:
			Flag01 = false
	if anim_state == "guard" and current_position > 0.94 and Flag01:
		guard_falg = false;
		state_machine.travel("idle")
	#print(current_position)
	target_position = Vector3(Player.transform.origin.x,transform.origin.y,Player.transform.origin.z)
	distance = transform.origin.distance_to(target_position)
	#print(distance)
	if not Flag00:
		look_at(target_position,Vector3.UP)
	if anim_state == "attack" and not Flag00 and Flag01:
		if not can_parry_flag and current_position > 0.52 and current_position < 0.6:
			can_parry_flag = true
		if attack_flag and current_position > 0.6:
			attack_flag = false
			can_parry_flag = false
			var effect_resource = preload("res://effect/Hit03.efkefc")
			var emitter = EffekseerEmitter3D.new()
			emitter.set_effect(effect_resource)
			emitter.transform.origin = EffecPos.transform.origin
			emitter.transform.basis = EffecPos.transform.basis
			#emitter.transform.scaled(Vector3(0.5,0.5,0.5))
			emitter.play()
			add_child(emitter)
			if player_enter_kick:
				player_skeleton.set("switch", true)
				Player.set("DamageFlag", false)
				audioplayer.play()
				#print(Flag)
		if current_position > 1.8:
			state_machine.travel("run")	
	if distance < 1.8 and not Flag00 and Flag01:
		if anim_state != "attack":
			var k_anim = k_state.get_current_node()
			var k_position = k_state.get_current_play_position ()
			#rint(k_position)
			if k_anim == "attack" and k_position > 0.36:
				guard_falg = true
				state_machine.travel("guard")
			else:
				guard_falg = false;
				attack_flag = true
				state_machine.travel("attack")
			#animation_player.speed_scale = 0.5
			velocity = gravity * delta
	elif not Flag00 and Flag01:
		if anim_state != "attack":
			if anim_state != "run":
				#nimation_player.speed_scale = 1
				guard_falg = false
				state_machine.travel("run")
			forward_direction = -global_transform.basis.z
			velocity = forward_direction * move_speed + gravity * delta
	if Flag00 and anim_state != "death" and Flag01:
		if anim_state != "damage":
			if can_parry_flag:
				can_parry_flag = false
			#animation_player.speed_scale = 1
			state_machine.travel("damage")
		elif current_position > 1.48:
			#animation_player.speed_scale = 1
			#guard_falg = false
			state_machine.travel("idle")
			Flag00 = false
	#print(current_position)
	move_and_slide()
	#print(self_skeleton.name)
	
func _on_body_entered(body):
	if body.is_in_group("Player"):
		#print("プレイヤーがエリアに入りました")
		if not player_enter_kick:
			player_enter_kick = true
func _on_Area_body_exited(body):
	if body.is_in_group("Player"):
		#print("プレイヤーがエリアを離れました")
		if player_enter_kick:
			player_enter_kick = false
		# ここでプレイヤーがエリアを離れたときの処理を行う
func flash_damage():
	if not guard_falg and Flag01:
		self_skeleton.set("switch", true)
		bar.value -= 20
		Flag00 = true
func parry():
	anim_state = state_machine.get_current_node()
	flash_damage()
	bar.value -= 10
	if anim_state != "damage":
		state_machine.travel("damage")
	if can_parry_flag:
		can_parry_flag = false
	
