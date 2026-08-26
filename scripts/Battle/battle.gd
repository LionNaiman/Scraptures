class_name Battle
extends Node

enum BattleState {
	INACTIVE,
	WAITING_FOR_PLAYER_ACTION,
	RESOLVING,
	ENDED
}

const BASIC_ATTACK_DAMAGE: int = 4

var current_state: BattleState = BattleState.INACTIVE
var player_scrapture: ScraptureRuntime
var enemy_scrapture: ScraptureRuntime


func initialize(
	player: ScraptureRuntime,
	enemy: ScraptureRuntime
) -> void:
	player_scrapture = player
	enemy_scrapture = enemy
	current_state = BattleState.WAITING_FOR_PLAYER_ACTION

	print(
		"Battle: ",
		player_scrapture.definition.display_name,
		" vs ",
		enemy_scrapture.definition.display_name
	)

	print("Waiting for player action.")
	
func get_first_scrapture() -> ScraptureRuntime: #trun order function which decides who gets the first move 
	if player_scrapture.get_final_speed() >= enemy_scrapture.get_final_speed():
		return player_scrapture

	return enemy_scrapture

func perform_basic_attack(
	attacker: ScraptureRuntime,
	defender: ScraptureRuntime
) -> void:
	if current_state == BattleState.ENDED:
		return
	defender.take_damage(BASIC_ATTACK_DAMAGE)
	

	print(
		attacker.definition.display_name,
		" attacks ",
		defender.definition.display_name,
		" for ",
		BASIC_ATTACK_DAMAGE,
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

func end_battle(defeated_scrapture: ScraptureRuntime) -> void: # Now the battle knows who won
	current_state = BattleState.ENDED

	if defeated_scrapture == enemy_scrapture:
		print("Player won the battle.")
	else:
		print("Player lost the battle.")

func perform_basic_attack_round() -> void:
	if current_state != BattleState.WAITING_FOR_PLAYER_ACTION:
		return

	current_state = BattleState.RESOLVING

	var first_scrapture: ScraptureRuntime = get_first_scrapture()

	if first_scrapture == player_scrapture:
		perform_basic_attack(player_scrapture, enemy_scrapture)
		perform_basic_attack(enemy_scrapture, player_scrapture)
	else:
		perform_basic_attack(enemy_scrapture, player_scrapture)
		perform_basic_attack(player_scrapture, enemy_scrapture)

	if current_state != BattleState.ENDED:
		current_state = BattleState.WAITING_FOR_PLAYER_ACTION
