# Task Board

## 当前阶段
- 阶段：M15：review / PR 信息准备
- 状态：已完成

## 当前里程碑范围
- 主菜单可进入游戏、设置与 About / Help
- 主菜单可进入 Credits
- 设置中有基础音量控制
- About / Help 提供项目说明与基础操作说明
- 单局开场有轻量按键提示，覆盖移动、射击、暂停及结果页关键操作
- 游戏中可暂停并返回主菜单
- 单局结束后进入独立结果页，可重开或返回主菜单
- 主菜单、设置、结果页中可看到展示版 build 信息

## 结论
- 当前已具备正式创建 PR 的条件。
- 当前分支相对 `main` 的新增范围为 4 个提交：阶段 21 的功能提交、M15 里程碑检查文档提交、M15 发布说明收口文档提交、M15 合回 `main` 准备检查文档提交；范围符合 `M15：完整展示版收尾` 预期。
- 当前更建议先做 review，再创建 PR。
- 建议 `base branch = main`，`compare branch = feature/stage-21-credits-and-finish-touch`。
- 建议 PR 标题：`feat(m15): add credits entry and final showcase polish`。
- 建议 PR 描述要点：Credits 入口、制作信息 / 作者标识、展示版说明、build 信息展示、当前版本达到“完整展示版收尾”标准。
