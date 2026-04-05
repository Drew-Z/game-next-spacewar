# Task Board

## 当前阶段

- 阶段：M3：review / PR 信息准备
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

## 里程碑检查结论

- [x] 已具备 `M3：可演示单局体验` 标准
- [x] 当前单局体验已可完整演示开局、交战、受压、失败/过关与局后提示过渡
- [x] 当前已具备正式创建 PR 的条件
- [x] 当前更适合先做 review，再通过 PR 从 `feature/stage-9-post-run-flow` 合回 `main`
- [x] 建议 PR：`base = main`，`compare = feature/stage-9-post-run-flow`
- [x] 建议 PR 标题：`feat(m3): deliver demo-ready single-run flow`

## 备注

- 当前仍未实现正式结算页面、分数系统、多关卡切换与复杂 UI。
- 当前分支相对 `main` 差异为 `0  4`，说明主线未落后，当前新增范围覆盖阶段 9 的局后提示补充与 M3 文档收口。
- 当前分支新增提交范围为：`feat(flow): add post-run status prompts`、`docs(milestone): close M3 demo loop check`、`docs(milestone): close M3 review and release notes`、`docs(milestone): record main merge readiness for M3`，边界仍然清晰。
- 当前建议的 PR 描述应覆盖：`CLEAR` / `FAIL` 结束态提示完善、`R` 重开在结束态中的过渡体验，以及当前单局体验已达到“可演示版本”标准。
