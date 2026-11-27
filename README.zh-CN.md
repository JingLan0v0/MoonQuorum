# MoonQuorum：加权投票配置迁移检查工具

在切换加权投票配置前，逐阶段检查会同时生效的策略是否可能产生不相交的法定
人数集合，以及节点停机后各策略能否达到阈值。报告给出首个失败阶段、冲突双方的
成员名单和权重缺口。核心分析全部由 MoonBit 实现。

已发布 **[JingLan0v0/quorum@0.3.4](https://mooncakes.io/docs/JingLan0v0/quorum@0.3.4)**，实际回执见 [验收记录](docs/acceptance.md)。
公开仓库：[JingLan0v0/MoonQuorum](https://github.com/JingLan0v0/MoonQuorum)。

## 一键复现故障域检查

按 `toolchain.json` 安装固定工具链，在项目根目录运行 `node examples/demo.mjs`。
五个投票节点都能承受任意单节点下线，但如果三个投票者集中在同一机房，整间机房
停机会把剩余权重降到 2，达不到阈值 3。重新分布后，最坏情况下仍可达到 3。
演示还会验证首个受影响的迁移阶段和重复归属节点的输入拒绝。[格式与算法](docs/resilience.md)

## 安装库

```sh
moon add JingLan0v0/quorum@0.3.4
```

在使用方 `moon.pkg` 中导入 `JingLan0v0/quorum`；调用示例见 `examples/library`。

## 多阶段迁移检查

```powershell
./scripts/moon.ps1 run cmd/main --target js -- --migration examples/migration-ready.json
./scripts/moon.ps1 run cmd/main --target js -- --migration examples/migration-bridge.json
./scripts/moon.ps1 run cmd/main --target js -- --migration examples/migration-outage.json
./scripts/moon.ps1 run examples/migration --target js
```

三个案例分别验证正常切换、过渡配置冲突和停机后的权重缺口。应用可通过
`check_migration` 读取结构化报告，也可使用 `--migration-batch` 批量检查。
[输入格式、输出与资源边界](docs/migration.md)

## 原有两配置场景

1. 读写配置评审：三个等权节点、读写阈值均为 2，结果为必定相交。
2. 成员切换评审：旧成员只在左策略有权重，新成员只在右策略有权重；返回不相交见证。
3. 维护停机评估：东区节点下线后，左策略剩余权重 1 小于阈值 2，右策略仍可达到 2。

```powershell
./scripts/moon.ps1 run cmd/main --target js -- examples/read-write.json
./scripts/moon.ps1 run cmd/main --target js -- examples/rollout.json
./scripts/moon.ps1 run cmd/main --target js -- examples/maintenance.json
./scripts/moon.ps1 run examples/library --target js
node scripts/verify.mjs
./scripts/powershell-smoke.ps1
```

使用 `toolchain.json` 中固定的编译器版本；本机复用项目外的独立工具链，未复制登录凭据。
详细 JSON 字段、库接口和其他环境用法见 [英文 README](README.md)。

## 如何理解结果

`intersecting` 表示给定两套加权阈值策略的集合交集性质成立。
`disjoint` 给出两组反例成员，可用 `verify_disjoint` 独立核验。
成员标识必须在两套配置中代表同一个实体；权重 0 可表示不参与某一侧。
下线名单只影响可用权重和可达阈值判断，不改变整个配置的交集结论。

这不是运行中的共识系统，不执行选举、签名、日志复制或配置切换；交集成立不等于
协议安全、拜占庭容错或运行时活性得到证明。结果依赖输入身份、权重和阈值的正确性。
工具不自动批准上线或操作远程节点。

32 个成员、单项权重 0～1000、每侧总权重不超过 4096，阈值必须在 1～总权重之间。
默认工作预算 200000；预算不足返回错误，不冒充“必定相交”。批处理中逐项隔离错误。
核心使用精确整数，按输入顺序输出确定性见证；不承诺反例集合的成员数最少。

本地验收包括两种构建模式、独立穷举对照、伪造见证、边界、输入输出和三场景检查。
迁移另有两种模式各 1,984 项独立穷举与生成对照。实际结果见 [验收记录](docs/acceptance.md)。CI 的实际运行结果单独记录。
赛事报名、资格和最终验收由官方确认，技术验证不能替代赛事审核。
