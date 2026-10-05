# 开发状态

更新时间：2026-10-06（Asia/Shanghai）。

当前目标：按用户最新指令移除 PassWall 1/2 及专用核心，两仓库公开，A/B 独立并行重编。

已完成：检查框架/源码/作者发布；保留 IPQ60XX-WIFI-YES 和 GENERAL；添加应用层 overlay、源锁、默认关闭服务、预检保护和完整交付流程。

构建策略：Public Ubuntu 24.04 runner 清理、原生 AUTOREMOVE、1G ccache 和磁盘保护；工具链/内核、最终固件两个串行任务，各段编译最多四小时。工具链完整源树检查点保留三天，支持同 Run 限时续编，最终固件拒绝未完成状态。源码锁、GENERAL/IPQ60XX-WIFI-YES 与作者底层脚本不变，应用 overlay 更新以移除 PassWall 专用依赖；配置检查要求选中包没有 Rust host 依赖。

验证：Bash 语法、ShellCheck、actionlint、差异检查通过。最新无 PassWall 预检 [Run 37335428676](https://github.com/zhaomeeng/Athena-VIKINGYFY/actions/runs/37335428676) 两个任务全部 success，工具链检查点到固件任务的恢复 PASS；protected.diff 和选中包 Rust host 依赖均为空。PassWall 1/2、Xray、Sing-box、Shadowsocks Rust 与 Ruby YJIT 均未启用，保留 OpenClash 所需 Ruby。最终配置 SHA256 为 a3dd345a4edd57d7cf0f274c282b787ccdce5f29aa95a31615a9e8396d45ccd3。预检框架 42b0e3c 与正式框架 1ff78b5 仅相差依赖条件名允许连字符的检查器修正，已用预检完整配置/包元数据复核。预检不编译固件或发布 Release，见 validation/preview-37335428676.json。

旧正式构建 [Run 37297257083](https://github.com/zhaomeeng/Athena-VIKINGYFY/actions/runs/37297257083) 已按用户要求取消，之前工具链成功、Rust 阶段未完成，无固件。本轮已完成全部本地 Git 历史凭据特征/敏感文件名检查，未命中，仓库为 Public；新正式构建 [Run 37338343637](https://github.com/zhaomeeng/Athena-VIKINGYFY/actions/runs/37338343637) 已启动，框架 1ff78b5，preview=false，目前工具链任务初始化中。旧配置/检查点不复用。

已知事项：前两次正式构建分别因磁盘耗尽、六小时上限失败，详见 BUILD_ISSUES.md。当前仅证实未编译源树的跨任务恢复；已编译工具链复用和真实限时续编尚待本次正式运行验证。最终固件任务失败时从完整工具链检查点重新执行，不复用半成品签名材料。完整镜像内容检查与设备测试未完成。当前 Windows 无可用 WSL 发行版，实际 defconfig/编译在 GitHub Ubuntu runner 执行。

下一步：完成本次正式构建，核验 Factory/Sysupgrade、packages/manifest 和 SHA-256。A/B 正式流程已并行启动，底层配置独立，尚无新版固件产物。

决策与需求：见 [BASELINE.md](BASELINE.md)、[REQUIREMENTS.md](REQUIREMENTS.md)、[OPERATIONS.md](OPERATIONS.md)。
