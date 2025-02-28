extends Skeleton3D

# ダメージを受けたときに使用するマテリアル
@export var damage_material: Material

# 各メッシュインスタンスの元のマテリアルを保持するリスト
var original_materials: Array = []

# 点滅の間隔（秒）
var blink_interval: float = 0.04

# 点滅を続ける時間（秒）
var blink_duration: float = 0.9

# 点滅処理中かどうかを追跡する変数
var is_blinking: bool = false
var blinking_elapsed: float = 0.0
var switch: bool = false
func _ready():
	# 元のマテリアルをリストに保存
	for child in get_children():
		if child is MeshInstance3D:
			original_materials.append(child.material_override)

func _process(delta):
	#print(switch)
	if switch and not is_blinking:
		switch = false
		take_damage()
	if is_blinking:
		update_blinking_effect(delta)

# 点滅処理を更新する関数
func update_blinking_effect(delta):
	blinking_elapsed += delta
	if blinking_elapsed >= blink_duration:
		# 点滅処理を終了し、元のマテリアルに戻す
		for i in range(len(get_children())):
			var child = get_child(i)
			if child is MeshInstance3D:
				child.material_override = original_materials[i]
		is_blinking = false
		blinking_elapsed = 0.0
	elif int(blinking_elapsed / blink_interval) % 2 == 0:
		# マテリアルをダメージ用のものに切り替える
		for child in get_children():
			if child is MeshInstance3D:
				child.material_override = damage_material
	else:
		# マテリアルを通常のものに戻す
		for i in range(len(get_children())):
			var child = get_child(i)
			if child is MeshInstance3D:
				child.material_override = original_materials[i]

# ゲーム中にダメージを受けたときに呼び出される関数
func take_damage():
	is_blinking = true
	blinking_elapsed = 0.0
	# 元のマテリアルをリセット
	for i in range(len(get_children())):
		var child = get_child(i)
		if child is MeshInstance3D:
			original_materials[i] = child.material_override
