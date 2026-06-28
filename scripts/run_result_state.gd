extends RefCounted
class_name RunResultState

const GAME_SCENE_PATH := "res://scenes/main.tscn"
const MENU_SCENE_PATH := "res://scenes/main_menu.tscn"

static var outcome_title := "试玩结果"
static var outcome_text := "结果：未知"
static var destroyed_count := 0
static var total_targets := 0
static var summary_text := "总结：试玩数据尚未准备好。"
static var build_text := "版本：展示版本 0.17"
static var score := 0
static var best_chain := 0
static var chain_bonus_score := 0


static func store_result(
	title: String,
	outcome: String,
	destroyed: int,
	total: int,
	summary: String,
	build: String,
	final_score: int = 0,
	final_best_chain: int = 0,
	final_chain_bonus_score: int = 0
) -> void:
	outcome_title = title
	outcome_text = outcome
	destroyed_count = destroyed
	total_targets = total
	summary_text = summary
	build_text = build
	score = final_score
	best_chain = final_best_chain
	chain_bonus_score = final_chain_bonus_score


static func reset() -> void:
	outcome_title = "试玩结果"
	outcome_text = "结果：未知"
	destroyed_count = 0
	total_targets = 0
	summary_text = "总结：试玩数据尚未准备好。"
	build_text = "版本：展示版本 0.17"
	score = 0
	best_chain = 0
	chain_bonus_score = 0
