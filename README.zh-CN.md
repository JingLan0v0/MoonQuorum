# MoonQuorum：加权法定人数配置检查工具

检查两套投票配置中的任意左右法定人数集合是否必定相交；如果不是，直接给出
两组互不相交、却各自达到阈值的成员名单，供开发者复核。同时计算指定节点下线后，
各策略是否还有足够权重达到阈值。核心分析全部由 MoonBit 实现。

已发布 **[JingLan0v0/quorum@0.1.0](https://mooncakes.io/docs/JingLan0v0/quorum@0.1.0)**，实际回执见 [验收记录](docs/acceptance.md)。
公开仓库：[JingLan0v0/MoonQuorum](https://github.com/JingLan0v0/MoonQuorum)。

## 安装库

```sh
moon add JingLan0v0/quorum@0.1.0
```

在使用方 `moon.pkg` 中导入 `JingLan0v0/quorum`；调用示例见 `examples/library`。

## 三个完整场景

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
实际结果见 [验收记录](docs/acceptance.md)。CI 的实际运行结果单独记录。
赛事报名、资格和最终验收由官方确认，技术验证不能替代赛事审核。
