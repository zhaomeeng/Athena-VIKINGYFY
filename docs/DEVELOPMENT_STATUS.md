# 开发状态

更新时间：2026-10-11（Asia/Shanghai）。

当前目标：仅修改 B 版，保留 OpenClash，额外加入 PassWall2（中文界面、Xray/Sing-box、nftables），通过真实预检后重新编译。

当前状态：[新预检 Run 38066247060](https://github.com/zhaomeeng/Athena-VIKINGYFY/actions/runs/38066247060)（框架 14ce3bd）两个任务均 success；真实 defconfig 与跨任务恢复通过，两段配置 SHA256 均为 bd6618a019b5b65757e572160d9db2d07d50094a5fd003edfcbbebc33bad7746，protected.diff 和有效 Rust 消费包列表均为空。OpenClash、PassWall2 中文界面、Xray/Sing-box、Docker 保留，见 validation/preview-38066247060.json。Bash 语法、ShellCheck、actionlint、差异检查通过；源锁及作者底层配置/脚本未变。[正式编译 Run 38067565477](https://github.com/zhaomeeng/Athena-VIKINGYFY/actions/runs/38067565477) 已于 2026-10-11 00:24:56（Asia/Shanghai）触发，框架 1239927 相对预检仅增加证据/状态文档，所有构建输入一致；结果待完成。

保持：源码 0fb9b10、feeds/插件版本锁、内核/NSS/无线/设备基线、Docker/Lucky/Aurora 等原有应用。PassWall 1 不选中；PassWall2 的可选 Shadowsocks Rust 和 Ruby YJIT 关闭，预检要求有效 Rust host 消费包为空。两套代理和 Docker 默认关闭，按需切换。

构建策略：Public Ubuntu 24.04 runner 清理、原生 AUTOREMOVE、1G ccache 和磁盘保护；工具链/内核、最终固件两个串行任务，各段编译最多四小时。工具链完整源树检查点保留三天，支持同 Run 限时续编，最终固件拒绝未完成状态。新配置不复用旧 Run 或预检检查点。

上一版交付：[Run 37397400157](https://github.com/zhaomeeng/Athena-VIKINGYFY/actions/runs/37397400157) 编译/镜像检查成功，[Release athena-b-37397400157](https://github.com/zhaomeeng/Athena-VIKINGYFY/releases/tag/athena-b-37397400157) 已公开，38 个资产摘要与原构建标签已核对，见 validation/release-37397400157.json。用户随后反馈 A/B 均能正常使用；该反馈对应之前无 PassWall2 的镜像，新组合仍需单独设备验证。

历史问题：磁盘耗尽、六小时上限、IPQ6018 文件名误判和零字节发布资产均有修复记录，见 BUILD_ISSUES.md；保留已经通过的分段固件检查与发布准备脚本。

已知事项：Windows 无可用 WSL 发行版，实际 defconfig/编译在 GitHub Ubuntu runner 执行。最终固件任务失败时从完整工具链检查点重新执行，不复用半成品签名材料。

下一步：正式编译完成后核对实际配置与预检一致、镜像中的双代理/双核心和默认关闭服务，以及固件/软件包和发布摘要；新镜像的 PassWall2 设备验证待交付后执行。失败时按实际步骤排查，发布失败优先补发已验证产物。

决策与需求：见 [BASELINE.md](BASELINE.md)、[REQUIREMENTS.md](REQUIREMENTS.md)、[OPERATIONS.md](OPERATIONS.md)。
