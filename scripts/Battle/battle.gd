class_name Battle
extends Node
signal battle_ended

enum BattleState {
	INACTIVE,
	WAITING_FOR_PLAYER_ACTION,
	RESOLVING,
	ENDED
}

enum BattleAction { 
	BASIC_ATTACK,
	GUARD
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
@onready var battle_ui: CanvasLayer = $BattleUI




func _ready() -> void:  #godot calls this func auto once battle.tcn enters the scene tree
	battle_ui.visible = false




func initialize(
	player: ScraptureRuntime,
	enemy: ScraptureRuntime
) -> void:
	player_scrapture = player
	enemy_scrapture = enemy
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


func end_battle(defeated_scrapture: ScraptureRuntime) -> void:
	current_state = BattleState.ENDED

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



func perform_round(player_action: BattleAction) -> void:
	if current_state != BattleState.WAITING_FOR_PLAYER_ACTION:
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
			GUARDED_DAMAGE
		)

	elif (
		player_action == BattleAction.GUARD
		and enemy_action == BattleAction.BASIC_ATTACK
	):
		perform_basic_attack(
			enemy_scrapture,
			player_scrapture,
			GUARDED_DAMAGE
		)
	
	update_health_display()

	if current_state != BattleState.ENDED:
		current_state = BattleState.WAITING_FOR_PLAYER_ACTION


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
