# Task Board

## 当前阶段
- 阶段：M13：review / PR 信息准备
- 状态：已完成

## 当前里程碑范围
- 主菜单可进入游戏、设置与 About / Help
- 设置中有基础音量控制
- About / Help 提供项目说明与基础操作说明
- 单局开场有轻量按键提示，覆盖移动、射击、暂停及结果页关键操作
- 游戏中可暂停并返回主菜单
- 单局结束后进入独立结果页，可重开或返回主菜单
- 主菜单、设置、结果页中可看到展示版 build 信息

## 结论
- 当前已具备“首局可理解展示版”标准。
- 当前分支相对 `main` 的新增范围为 4 个提交：阶段 19 功能提交、M13 里程碑检查文档提交、M13 发布说明收口文档提交、M13 合回 main 准备检查文档提交。
- 当前已具备正式创建 PR 的条件，且建议先做 review，再创建 PR。
- 建议 `base branch = main`，`compare branch = feature/stage-19-keyboard-hint-and-first-run-guidance`。
- 建议 PR 标题：`feat(m13): add first-run keyboard guidance`。
- 建议 PR 描述要点：首局轻量按键提示、覆盖移动/射击/暂停/结果页关键操作、提示会自动消失或在首次相关操作后隐藏、当前版本达到“首局可理解展示版”标准。
