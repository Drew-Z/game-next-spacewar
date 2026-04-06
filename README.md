# game-next-spacewar

`game-next-spacewar` 是一个使用 Godot 开发、使用 Git 进行版本管理的本地游戏项目。

## 当前状态

- 当前阶段：M8：完整展示流程里程碑检查
- 引擎版本：Godot 4.6.1
- 当前范围：已形成带主菜单、设置入口与暂停返回能力的可试玩展示版，包含单局完整闭环、结果面板、总结信息、下一步入口提示与最小音量控制

## 当前项目结构

- `project.godot`：Godot 项目入口配置
- `scenes/main.tscn`：当前可运行的主场景
- `scenes/player.tscn`：玩家战机场景
- `scenes/bullet.tscn`：玩家子弹场景
- `scenes/enemy_target.tscn`：最小敌机目标场景
- `scenes/obstacle.tscn`：最小障碍物场景
- `scripts/main.gd`：主场景状态与 HUD 更新脚本
- `scripts/player.gd`：玩家移动与射击脚本
- `scripts/bullet.gd`：子弹前进脚本
- `scripts/enemy_target.gd`：敌机移动与命中反馈脚本
- `scripts/obstacle.gd`：障碍物移动与接触伤害脚本
- `docs/task-board.md`：阶段看板
- `docs/rules.md`：核心玩法规则定义
- `docs/roadmap.md`：轻量阶段路线
- `docs/test-checklist.md`：当前可执行验证项

## 运行方式

可在项目根目录使用本地 Godot 打开工程，或通过命令行执行：

```powershell
D:\Development\Godot\godot.cmd --path D:\workspace4Codex\game-next-spacewar
```
