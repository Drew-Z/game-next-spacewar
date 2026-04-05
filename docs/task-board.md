# Task Board

## 当前阶段

- 阶段：M2：review / PR 信息准备
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

## 里程碑检查结论

- [x] 已具备 `M2：单局闭环稳定版` 标准
- [x] 单局从开局、受压、生存、清场到失败/过关/重开都已闭合
- [x] 当前分支已覆盖 M2 所需提交范围
- [x] 当前已具备正式创建 PR 的条件
- [x] 当前更适合先做 review，再通过 PR 从 `feature/stage-8-clear-consistency` 合回 `main`
- [x] 建议 PR：`base = main`，`compare = feature/stage-8-clear-consistency`
- [x] 建议 PR 标题：`feat(m2): stabilize single-run gameplay loop`

## 备注

- 当前已达到单局闭环稳定版，但仍不包含多关卡切换、分数系统、复杂波次与复杂 UI。
- 当前主线未落后：`main...HEAD` 差异为 `0  6`，说明 `main` 没有额外提交，当前分支边界仍然清晰。
- 当前建议的 PR 描述应覆盖：玩家移动与射击、敌机命中与清除、障碍物压力、玩家受伤与失败、失败后重开、清场过关、敌机离场不阻塞清场。
