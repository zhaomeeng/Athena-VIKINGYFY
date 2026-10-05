# 开发状态

更新时间：2026-10-05（Asia/Shanghai）。

当前目标：优先完成 B 版应用调整、配置预检与首轮编译。

已完成：检查框架/源码/作者发布；保留 IPQ60XX-WIFI-YES 和 GENERAL；添加应用层 overlay、源锁、默认关闭服务、预检保护和完整交付流程。

本地 Bash 语法、actionlint 和已暂存差异检查通过；已创建并推送 zhaomeeng/Athena-VIKINGYFY（main）。新仓库工作流注册问题已解决，预检 Run [37241333236](https://github.com/zhaomeeng/Athena-VIKINGYFY/actions/runs/37241333236) 已成功通过，基于 `8311a047dc823baa24e4def345c085b16fece742`。

实际证据：protected.diff 为 0 字节，必需应用全部启用、删除应用全部排除；附加检查 NSS/ATH11K/IPQ/SKB_RECYCLER/CPU frequency 配置相同。Docker 自动选择 4 项 cgroup 及原生 bridge/iptables 兼容依赖，没有修改 Firewall/NSS 实现。详见 validation/preview-37241333236.json。

正式编译已失败：[Run 37241920846](https://github.com/zhaomeeng/Athena-VIKINGYFY/actions/runs/37241920846)，框架提交 `4d82efacb1b456966426f8b74c3e8c2d07c0d5cc`，与预检使用同一 build.lock.tsv 和应用配置。运行时间为 2026-10-05 06:56:45 至 08:25:32（Asia/Shanghai）。GitHub 检查注释确认 runner 磁盘耗尽：`System.IO.IOException: No space left on device`。

本次正式运行的 Custom Settings/配置预检和 Download Packages 均成功，已下载配置证据并确认 preflight PASS、protected.diff 为 0 字节。只有配置 artifact；没有固件 artifact 或 Release。runner 异常退出后完整 job 日志不可获取（`log not found`），不推断具体软件包编译错误。

用户已授权继续。已补充临时 runner 预装 SDK/cache 清理、原生 AUTOREMOVE、1G ccache 上限和磁盘监控/诊断，锁定 Ubuntu 24.04；源码/锁/应用配置与底层实现保持原值。Bash 语法、actionlint、差异检查通过。

第二次正式构建已结束：[Run 37253202265](https://github.com/zhaomeeng/Athena-VIKINGYFY/actions/runs/37253202265)，框架提交 `8df827caaa85a35a2b5dc86b61a356923110c5be`，2026-10-05 09:53:36 至 15:53:59（Asia/Shanghai）。GitHub 检查注释确认任务超过 6 小时最大执行时间，结论 cancelled。清理前可用 14G、清理后 45G、安装环境后 42G；编译期间记录的最低空间约 20.0 GiB，取消前最后记录约 20.7 GiB，没有触发磁盘保护。配置预检再次 PASS，protected.diff 为 0 字节，final.config SHA-256 与首次正式构建相同。配置及诊断 artifact 和完整运行日志已下载，未产生固件 artifact 或 Release。详见 validation/build-space-37253202265.json 与 BUILD_ISSUES.md。

下一步：处理完整构建超时与构建缓存恢复，再使用同一源码锁和应用配置重编、核验最终镜像交付。本次仅检查并记录结果，未触发第三次构建。B 版成功后实施 A 版。

已知阻塞：当前 runner 从空缓存编译未能在 6 小时任务上限内完成，超时后 Save Build Cache 被跳过；完整编译及镜像内容验证仍未通过。取消时没有生成编译后快照与配置哈希，不能宣称编译前后配置一致检查已完成。当前 Windows 没有可用 WSL Linux 发行版，实际 defconfig 与编译使用 GitHub Ubuntu runner。

决策与需求：见 [BASELINE.md](BASELINE.md)、[REQUIREMENTS.md](REQUIREMENTS.md)、[OPERATIONS.md](OPERATIONS.md)。
