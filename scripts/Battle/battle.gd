class_name Battle
extends Node
signal battle_ended
signal scrapture_captured(scrapture: ScraptureRuntime)

enum BattleState {
	INACTIVE,
	WAITING_FOR_PLAYER_ACTION,
	RESOLVING,
	ENDED
}

enum BattleAction { 
	BASIC_ATTACK,
	GUARD,
	GRANTED_MOVE
}

const BASIC_ATTACK_DAMAGE: int = 4
const GUARDED_DAMAGE: int = 2

var current_state: BattleState = BattleState.INACTIVE
var player_scrapture: ScraptureRuntime
var enemy_scrapture: ScraptureRuntime
@onready var player_health_label: Label = (
	$BattleUI/HealthDisplay/PlayerHealthLabel
)

@onready var enemy_health_label: Label = (
	$BattleUI/HealthDisplay/EnemyHealthLabel
)
@onready var result_label: Label = (
	$BattleUI/HealthDisplay/ResultLabel
)
@onready var battle_ui: CanvasLayer = $BattleUI # UI layer for the battle UI 
@onready var module_move_1_button: Button = ( 
	$BattleUI/ActionMenu/ModuleMove1Button
)
@onready var module_move_2_button: Button = (
	$BattleUI/ActionMenu/ModuleMove2Button
)

@onready var action_menu: VBoxContainer = (
	$BattleUI/ActionMenu
)



func _ready() -> void:  #godot calls this func auto once battle.tcn enters the scene tree
	battle_ui.visible = false




func initialize(
	player: ScraptureRuntime,
	enemy: ScraptureRuntime
) -> void:
	action_menu.visible = true
	player_scrapture = player
	enemy_scrapture = enemy
	update_module_move_buttons()
	battle_ui.visible = true
	current_state = BattleState.WAITING_FOR_PLAYER_ACTION
	result_label.text = ""

	print(
		"Battle: ",
		player_scrapture.definition.display_name,
		" vs ",
		enemy_scrapture.definition.display_name
	)

	print("Waiting for player action.")
	var granted_moves: Array[MoveDefinition] = player_scrapture.get_granted_moves()

	for move: MoveDefinition in granted_moves:
		print("Granted move: ", move.display_name)
	update_health_display()
	result_label.text = ""



func is_active() -> bool:
	return (
		current_state != BattleState.INACTIVE
		and current_state != BattleState.ENDED
	)



func choose_enemy_action() -> BattleAction:
	var half_health: float = enemy_scrapture.get_final_max_health() / 2.0

	if enemy_scrapture.current_health <= half_health:
		return BattleAction.GUARD

	return BattleAction.BASIC_ATTACK
	


func get_first_scrapture() -> ScraptureRuntime: # trun order function which decides who gets the first move
	if player_scrapture.get_final_speed() >= enemy_scrapture.get_final_speed():
		return player_scrapture

	return enemy_scrapture



func perform_basic_attack(
	attacker: ScraptureRuntime,
	defender: ScraptureRuntime,
	damage: int = BASIC_ATTACK_DAMAGE
) -> void:
	if current_state == BattleState.ENDED:
		return

	defender.take_damage(damage)

	print(
		attacker.definition.display_name,
		" attacks ",
		defender.definition.display_name,
		" for ",
		damage,
		" damage."
	)

	print(
		defender.definition.display_name,
		" HP: ",
		defender.current_health
	)

	if defender.is_defeated():
		print(
			defender.definition.display_name,
			" was defeated."
		)
		end_battle(defender)

func get_guarded_damage(damage: int) -> int:
	return maxi(1, int(damage * 0.5))




func end_battle(defeated_scrapture: ScraptureRuntime) -> void:
	current_state = BattleState.ENDED
	action_menu.visible = false
	if defeated_scrapture == enemy_scrapture:
		print("Player won the battle.")
		result_label.text = "Victory!"
	else:
		print("Player lost the battle.")
		result_label.text = "Defeat!"
	
	battle_ended.emit()

func perform_basic_attack_round() -> void:
	perform_round(BattleAction.BASIC_ATTACK)


func perform_guard_round() -> void:
	perform_round(BattleAction.GUARD)



func perform_round(
	player_action: BattleAction,
	selected_move: MoveDefinition = null
) -> void:
	if current_state != BattleState.WAITING_FOR_PLAYER_ACTION:
		return
	if (
		player_action == BattleAction.GRANTED_MOVE
		and selected_move == null
	):
		
		return

	current_state = BattleState.RESOLVING

	var enemy_action: BattleAction = choose_enemy_action()

	if player_action == BattleAction.GUARD:
		print(
			player_scrapture.definition.display_name,
			" guards."
		)

	if enemy_action == BattleAction.GUARD:
		print(
			enemy_scrapture.definition.display_name,
			" guards."
		)

	if (
		player_action == BattleAction.BASIC_ATTACK
		and enemy_action == BattleAction.BASIC_ATTACK
	):
		var first_scrapture: ScraptureRuntime = get_first_scrapture()

		if first_scrapture == player_scrapture:
			perform_basic_attack(player_scrapture, enemy_scrapture)

			if current_state != BattleState.ENDED:
				perform_basic_attack(enemy_scrapture, player_scrapture)
		else:
			perform_basic_attack(enemy_scrapture, player_scrapture)

			if current_state != BattleState.ENDED:
				perform_basic_attack(player_scrapture, enemy_scrapture)

	elif (
		player_action == BattleAction.BASIC_ATTACK
		and enemy_action == BattleAction.GUARD
	):
		perform_basic_attack(
			player_scrapture,
			enemy_scrapture,
			get_guarded_damage(BASIC_ATTACK_DAMAGE)

		)

	elif (
		player_action == BattleAction.GUARD
		and enemy_action == BattleAction.BASIC_ATTACK
	):
		perform_basic_attack(
			enemy_scrapture,
			player_scrapture,
			get_guarded_damage(BASIC_ATTACK_DAMAGE)
		)
	elif (
		player_action == BattleAction.GRANTED_MOVE
		and enemy_action == BattleAction.GUARD
	):
		

		print(
			player_scrapture.definition.display_name,
			" uses ",
			selected_move.display_name,
			"."
		)

		perform_basic_attack(
			player_scrapture,
			enemy_scrapture,
			get_guarded_damage(selected_move.damage)
		)
	elif (
		player_action == BattleAction.GRANTED_MOVE
		and enemy_action == BattleAction.BASIC_ATTACK
	):
		var first_scrapture: ScraptureRuntime = get_first_scrapture()

		if first_scrapture == player_scrapture:
			print(
				player_scrapture.definition.display_name,
				" uses ",
				selected_move.display_name,
				"."
			)

			perform_basic_attack(
				player_scrapture,
				enemy_scrapture,
				selected_move.damage
			)

			if current_state != BattleState.ENDED:
				perform_basic_attack(
					enemy_scrapture,
					player_scrapture
				)

		else:
			perform_basic_attack(
				enemy_scrapture,
				player_scrapture
			)

			if current_state != BattleState.ENDED:
				print(
					player_scrapture.definition.display_name,
					" uses ",
					selected_move.display_name,
					"."
				)

				perform_basic_attack(
					player_scrapture,
					enemy_scrapture,
					selected_move.damage
				)
		
		update_health_display()

	if current_state != BattleState.ENDED:
		current_state = BattleState.WAITING_FOR_PLAYER_ACTION

func perform_granted_move_round(
	move: MoveDefinition = null
) -> void:
	if current_state != BattleState.WAITING_FOR_PLAYER_ACTION:
		return

	var granted_moves: Array[MoveDefinition] = (
		player_scrapture.get_granted_moves()
	)

	if granted_moves.is_empty():
		print("No module-granted move available.")
		return

	var selected_move: MoveDefinition = move

	if selected_move == null:
		selected_move = granted_moves[0]

	if not granted_moves.has(selected_move):
		print("Move is not currently available.")
		return

	if selected_move.move_kind == MoveDefinition.MoveKind.GUARD:
		print(
			player_scrapture.definition.display_name,
			" uses ",
			selected_move.display_name,
			"."
		)

		perform_round(BattleAction.GUARD)
		return

	perform_round(
		BattleAction.GRANTED_MOVE,
		selected_move
	)

func can_capture_enemy() -> bool: # check if the enemy is close to being defeated
	if enemy_scrapture == null:
		return false

	if enemy_scrapture.is_defeated():
		return false

	var capture_threshold: float = (
		enemy_scrapture.get_final_max_health() * 0.30
	)

	return enemy_scrapture.current_health <= capture_threshold

func perform_capture_attempt() -> void:
	if current_state != BattleState.WAITING_FOR_PLAYER_ACTION:
		return

	if not can_capture_enemy():
		print("Capture failed. Weaken the enemy first.")
		return

	current_state = BattleState.ENDED
	action_menu.visible = false
	print(
		"Captured ",
		enemy_scrapture.definition.display_name,
		"!"
	)

	result_label.text = "Captured!"

	scrapture_captured.emit(enemy_scrapture)
	battle_ended.emit()

func perform_granted_move_at_index(index: int) -> void:
	if current_state != BattleState.WAITING_FOR_PLAYER_ACTION:
		return

	var granted_moves: Array[MoveDefinition] = (
		player_scrapture.get_granted_moves()
	)

	if index < 0 or index >= granted_moves.size():
		print("No granted move at index: ", index)
		return

	var selected_move: MoveDefinition = granted_moves[index]

	perform_granted_move_round(selected_move)


#----------------------------- UI ---------------------------

func update_health_display() -> void:
	player_health_label.text = (
		player_scrapture.definition.display_name
		+ " HP: "
		+ str(player_scrapture.current_health)
		+ " / "
		+ str(player_scrapture.get_final_max_health())
	)

	enemy_health_label.text = (
		enemy_scrapture.definition.display_name
		+ " HP: "
		+ str(enemy_scrapture.current_health)
		+ " / "
		+ str(enemy_scrapture.get_final_max_health())
	)

func update_module_move_buttons() -> void:
	var granted_moves: Array[MoveDefinition] = (
		player_scrapture.get_granted_moves()
	)

	module_move_1_button.visible = false
	module_move_2_button.visible = false

	if granted_moves.size() >= 1:
		module_move_1_button.visible = true
		module_move_1_button.text = (
			granted_moves[0].display_name
		)

	if granted_moves.size() >= 2:
		module_move_2_button.visible = true
		module_move_2_button.text = (
			granted_moves[1].display_name
		)

func _on_basic_attack_button_pressed() -> void:
	perform_basic_attack_round()


func _on_guard_button_pressed() -> void:
	perform_guard_round()

func _on_capture_button_pressed() -> void:
	perform_capture_attempt()


func _on_module_move_1_button_pressed() -> void:
	perform_granted_move_at_index(0)


func _on_module_move_2_button_pressed() -> void:
	perform_granted_move_at_index(1)
