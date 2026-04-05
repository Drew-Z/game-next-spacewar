# Task Board

## 当前阶段

- 阶段：M5：review / PR 信息准备
- 状态：已完成

## 里程碑检查范围

- 玩家移动
- 玩家射击
- 子弹命中敌机
- 障碍物压力
- 玩家受伤与失败
- 失败后重开
- 清场过关
- 敌机离场不阻塞清场
- [x] `FAIL` 状态明确提示可按 `R` 重开
- [x] `CLEAR` 状态也明确提示可按 `R` 重开
- [x] 局后界面补充了下一步占位提示，结束态表达更完整
- [x] 原有移动、射击、受伤、失败、重开与清场闭环继续成立
- [x] `CLEAR` 与 `FAIL` 后会显示更明确的结算信息
- [x] 结算中会展示最基础的击毁敌机数与结果状态
- [x] 结算展示与按 `R` 重开流程兼容
- [x] 当前单局闭环仍然成立，不受结算补充影响
- [x] 单局结束后会显示更明确的总结信息
- [x] 玩家可以在结果面板中直接看到“再来一局”的下一步入口
- [x] 结果面板补充了当前版本完成度与后续内容占位提示
- [x] 原有移动、射击、命中、受伤、过关、重开与结果面板闭环继续成立

## 里程碑检查结论

- [x] 已具备 `M5：可试玩展示版` 标准
- [x] 当前单局体验已可完整演示开局、交战、受压、失败/过关、结算、总结与下一步入口
- [x] 当前已具备正式创建 PR 的条件
- [x] 当前更适合先做 review，再通过 PR 从 `feature/stage-11-run-summary-and-next-step` 合回 `main`
- [x] 建议 PR：`base = main`，`compare = feature/stage-11-run-summary-and-next-step`
- [x] 建议 PR 标题：`feat(m5): deliver playable showcase build`

## 备注

- 当前仍未实现正式主菜单、多关卡切换、排行榜与复杂动画。
- 当前分支相对 `main` 差异为 `0  4`，说明主线未落后，当前新增范围覆盖阶段 11 的总结信息补充与 M5 文档收口。
- 当前分支新增提交范围为：`feat(flow): add run summary and next-step hints`、`docs(milestone): close M5 playable demo check`、`docs(milestone): close M5 review and release notes`、`docs(milestone): record main merge readiness for M5`，边界仍然清晰。
- 当前建议的 PR 描述应覆盖：结果面板、基础击毁统计、单局总结信息、下一步入口提示，以及当前版本已达到“可试玩展示版”标准。
