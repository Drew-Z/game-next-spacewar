# Test Checklist

## 阶段 0：初始化

- [ ] `git branch --show-current` 返回 `feature/stage-0-initialization`
- [ ] `git remote -v` 中存在 `origin`
- [ ] 项目根目录存在 `project.godot`
- [ ] Godot 可以识别并打开该项目
- [ ] `scenes/main.tscn` 可以作为主场景加载

## 阶段 2：玩家基础控制与射击

- [ ] 运行项目后可直接进入主场景
- [ ] 使用方向键或 `WASD` 可以控制飞机上下左右移动
- [ ] 按 `Space` 或回车可持续发射子弹
- [ ] 子弹会从玩家前方生成并向上飞行
- [ ] 玩家与子弹都不会立即超出屏幕边界
