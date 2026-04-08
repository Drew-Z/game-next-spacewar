extends RefCounted
class_name RunResultState

const GAME_SCENE_PATH := "res://scenes/main.tscn"
const MENU_SCENE_PATH := "res://scenes/main_menu.tscn"

static var outcome_title := "RUN RESULT"
static var outcome_text := "Result: Unknown"
static var destroyed_count := 0
static var total_targets := 0
static var summary_text := "Summary: Run data is not ready yet."
static var build_text := "Build: Showcase flow update pending"


static func store_result(title: String, outcome: String, destroyed: int, total: int, summary: String, build: String) -> void:
	outcome_title = title
	outcome_text = outcome
	destroyed_count = destroyed
	total_targets = total
	summary_text = summary
	build_text = build


static func reset() -> void:
	outcome_title = "RUN RESULT"
	outcome_text = "Result: Unknown"
	destroyed_count = 0
	total_targets = 0
	summary_text = "Summary: Run data is not ready yet."
	build_text = "Build: Showcase flow update pending"
