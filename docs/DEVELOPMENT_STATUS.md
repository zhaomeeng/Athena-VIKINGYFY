# 开发状态

更新时间：2026-10-06（Asia/Shanghai）。

当前目标：按用户最新指令移除 PassWall 1/2 及专用核心，两仓库公开，A/B 独立并行重编。

已完成：检查框架/源码/作者发布；保留 IPQ60XX-WIFI-YES 和 GENERAL；添加应用层 overlay、源锁、默认关闭服务、预检保护和完整交付流程。

构建策略：Public Ubuntu 24.04 runner 清理、原生 AUTOREMOVE、1G ccache 和磁盘保护；工具链/内核、最终固件两个串行任务，各段编译最多四小时。工具链完整源树检查点保留三天，支持同 Run 限时续编，最终固件拒绝未完成状态。源码锁、GENERAL/IPQ60XX-WIFI-YES 与作者底层脚本不变，应用 overlay 更新以移除 PassWall 专用依赖；配置检查要求选中包没有 Rust host 依赖。

验证：Bash 语法、ShellCheck、actionlint、差异检查通过。分阶段预检 [Run 37294364565](https://github.com/zhaomeeng/Athena-VIKINGYFY/actions/runs/37294364565) 三个任务全部 success，两次源树恢复均 PASS；protected.diff 为 0 字节，最终配置 SHA-256 与前两次正式构建相同。预检不执行固件编译或 Release；证据见 validation/preview-37294364565.json。预检后仅修正工作流引用和诊断记录保留，构建输入与配置不变。

旧正式构建 [Run 37297257083](https://github.com/zhaomeeng/Athena-VIKINGYFY/actions/runs/37297257083) 已按用户要求取消，之前工具链成功、Rust 阶段未完成，无固件。本轮已完成全部本地 Git 历史凭据特征/敏感文件名检查，未命中，仓库已公开；待新版真实预检后启动新的正式构建，旧配置/检查点不复用。

已知事项：前两次正式构建分别因磁盘耗尽、六小时上限失败，详见 BUILD_ISSUES.md。当前仅证实未编译源树的跨任务恢复；已编译工具链/Rust 的复用和真实限时续编尚待本次正式运行验证。完整镜像内容检查与设备测试未完成。当前 Windows 无可用 WSL 发行版，实际 defconfig/编译在 GitHub Ubuntu runner 执行。

下一步：新版真实预检、跨任务恢复通过后立即启动 B 正式构建；核验 Factory/Sysupgrade、packages/manifest 和 SHA-256。A/B 并行、独立底层配置。

决策与需求：见 [BASELINE.md](BASELINE.md)、[REQUIREMENTS.md](REQUIREMENTS.md)、[OPERATIONS.md](OPERATIONS.md)。
