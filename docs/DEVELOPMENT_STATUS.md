# 开发状态

更新时间：2026-10-05（Asia/Shanghai）。

当前目标：优先完成 B 版应用调整、配置预检与首轮编译。

已完成：检查框架/源码/作者发布；保留 IPQ60XX-WIFI-YES 和 GENERAL；添加应用层 overlay、源锁、默认关闭服务、预检保护和完整交付流程。

本地 Bash 语法、actionlint 和已暂存差异检查通过；已创建并推送 zhaomeeng/Athena-VIKINGYFY（main）。新仓库工作流注册问题已解决，预检 Run [37241333236](https://github.com/zhaomeeng/Athena-VIKINGYFY/actions/runs/37241333236) 已成功通过，基于 `8311a047dc823baa24e4def345c085b16fece742`。

实际证据：protected.diff 为 0 字节，必需应用全部启用、删除应用全部排除；附加检查 NSS/ATH11K/IPQ/SKB_RECYCLER/CPU frequency 配置相同。Docker 自动选择 4 项 cgroup 及原生 bridge/iptables 兼容依赖，没有修改 Firewall/NSS 实现。详见 validation/preview-37241333236.json。

正式编译已触发：[Run 37241920846](https://github.com/zhaomeeng/Athena-VIKINGYFY/actions/runs/37241920846)，框架提交 `4d82efacb1b456966426f8b74c3e8c2d07c0d5cc`，与预检使用同一 build.lock.tsv 和应用配置。该次编译尚未完成，不存在定制成功固件或实机验证结论。

下一步：检查正式编译结果；普通应用依赖问题按授权修复，若涉及受保护底层则停止报告。B 版成功后实施 A 版。

阻塞：当前 Windows 没有可用 WSL Linux 发行版，实际 defconfig 与编译使用 GitHub Ubuntu runner。

决策与需求：见 [BASELINE.md](BASELINE.md)、[REQUIREMENTS.md](REQUIREMENTS.md)、[OPERATIONS.md](OPERATIONS.md)。
