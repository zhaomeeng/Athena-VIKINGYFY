# 开发状态

更新时间：2026-10-05（Asia/Shanghai）。

当前目标：完成 B 版完整编译和镜像交付，通过后再实施 A 版。

已完成：检查框架/源码/作者发布；保留 IPQ60XX-WIFI-YES 和 GENERAL；添加应用层 overlay、源锁、默认关闭服务、预检保护和完整交付流程。

构建策略：Ubuntu 24.04 临时 runner 清理、原生 AUTOREMOVE、1G ccache 和磁盘保护；工具链/内核、Rust 主机编译器、最终固件三个串行任务，各段编译最多五小时。完整源树检查点保留三天，支持同一次 Run 重跑失败阶段；Rust 限时退出另存未完成检查点，最终固件不能消费未完成状态。源码锁、应用 overlay、GENERAL/IPQ60XX-WIFI-YES 与作者底层脚本不变。

验证：Bash 语法、ShellCheck、actionlint、差异检查通过。分阶段预检 [Run 37294364565](https://github.com/zhaomeeng/Athena-VIKINGYFY/actions/runs/37294364565) 三个任务全部 success，两次源树恢复均 PASS；protected.diff 为 0 字节，最终配置 SHA-256 与前两次正式构建相同。预检不执行固件编译或 Release；证据见 validation/preview-37294364565.json。预检后仅修正工作流引用和诊断记录保留，构建输入与配置不变。

当前正式构建：[Run 37297257083](https://github.com/zhaomeeng/Athena-VIKINGYFY/actions/runs/37297257083)，框架提交 `621a8df186f1e669af491ab37fb2cdd6b18b7046`，2026-10-05 18:32:43（Asia/Shanghai）启动，正在第一个任务的环境准备阶段；尚无定制成功固件。

已知事项：前两次正式构建分别因磁盘耗尽、六小时上限失败，详见 BUILD_ISSUES.md。当前仅证实未编译源树的跨任务恢复；已编译工具链/Rust 的复用和真实限时续编尚待本次正式运行验证。完整镜像内容检查与设备测试未完成。当前 Windows 无可用 WSL 发行版，实际 defconfig/编译在 GitHub Ubuntu runner 执行。

下一步：检查三阶段正式结果和配置哈希、检查点/磁盘诊断，核验 Factory/Sysupgrade、packages/manifest 和 SHA-256；B 版成功后实施 A 版。

决策与需求：见 [BASELINE.md](BASELINE.md)、[REQUIREMENTS.md](REQUIREMENTS.md)、[OPERATIONS.md](OPERATIONS.md)。
