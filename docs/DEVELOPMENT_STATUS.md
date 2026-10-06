# 开发状态

更新时间：2026-10-06（Asia/Shanghai）。

当前状态：[Run 37397400157](https://github.com/zhaomeeng/Athena-VIKINGYFY/actions/runs/37397400157)（构建框架 1ce469a）工具链/固件编译、根文件系统交付检查和固件 artifact 上传全部成功；原 Release 的两个零字节证据上传失败已修复。[B 版 Release](https://github.com/zhaomeeng/Athena-VIKINGYFY/releases/tag/athena-b-37397400157) 已公开，38 个资产的远端摘要与发布清单全部匹配，标签核对为原构建提交，固件/软件包字节未改变。实际配置 SHA256 与预检相同，底层保护和 Rust 消费包差异为空；IPQ6018 MDT/分段、QCN9074、OpenClash 和 Docker 镜像检查通过。证据见 validation/release-37397400157.json。设备运行尚未验证。

当前目标：按用户最新指令移除 PassWall 1/2 及专用核心，两仓库公开，A/B 独立并行重编。

已完成：检查框架/源码/作者发布；保留 IPQ60XX-WIFI-YES 和 GENERAL；添加应用层 overlay、源锁、默认关闭服务、预检保护和完整交付流程。

构建策略：Public Ubuntu 24.04 runner 清理、原生 AUTOREMOVE、1G ccache 和磁盘保护；工具链/内核、最终固件两个串行任务，各段编译最多四小时。工具链完整源树检查点保留三天，支持同 Run 限时续编，最终固件拒绝未完成状态。源码锁、GENERAL/IPQ60XX-WIFI-YES 与作者底层脚本不变，应用 overlay 更新以移除 PassWall 专用依赖；配置检查要求选中包没有 Rust host 依赖。

验证：Bash 语法、ShellCheck、actionlint、差异检查通过。最新无 PassWall 预检 [Run 37335428676](https://github.com/zhaomeeng/Athena-VIKINGYFY/actions/runs/37335428676) 两个任务全部 success，工具链检查点到固件任务的恢复 PASS；protected.diff 和选中包 Rust host 依赖均为空。PassWall 1/2、Xray、Sing-box、Shadowsocks Rust 与 Ruby YJIT 均未启用，保留 OpenClash 所需 Ruby。最终配置 SHA256 为 a3dd345a4edd57d7cf0f274c282b787ccdce5f29aa95a31615a9e8396d45ccd3。预检框架 42b0e3c 与正式框架 1ff78b5 仅相差依赖条件名允许连字符的检查器修正，已用预检完整配置/包元数据复核。预检不编译固件或发布 Release，见 validation/preview-37335428676.json。

旧正式构建 [Run 37297257083](https://github.com/zhaomeeng/Athena-VIKINGYFY/actions/runs/37297257083) 已按用户要求取消。本轮已完成全部本地 Git 历史凭据特征/敏感文件名检查，未命中，仓库为 Public。[Run 37338343637](https://github.com/zhaomeeng/Athena-VIKINGYFY/actions/runs/37338343637) 工具链、固件编译均成功，交付检查错误要求 IPQ6018/amss.bin 而失败，未发布固件。已根据固定固件修订纠正为 MDT/完整分段检查，补充打包后诊断保留；Bash/ShellCheck/actionlint/差异检查通过，待修复后新正式运行。配置、源锁与底层脚本没有变化。

已知事项：前两次正式构建分别因磁盘耗尽、六小时上限失败，详见 BUILD_ISSUES.md。已编译工具链复用已由 Run 37338343637 证实，真实限时续编尚未触发。最终固件任务失败时从完整工具链检查点重新执行，不复用半成品签名材料。完整镜像内容检查与设备测试未完成。当前 Windows 无可用 WSL 发行版，实际 defconfig/编译在 GitHub Ubuntu runner 执行。

下一步：下载后在刷机电脑再次校验 SHA-256；实机启动、NSS、有线和 Wi-Fi 80/160MHz 验证待用户执行。A/B 底层配置仍独立，无云端编译/发布阻塞。

决策与需求：见 [BASELINE.md](BASELINE.md)、[REQUIREMENTS.md](REQUIREMENTS.md)、[OPERATIONS.md](OPERATIONS.md)。
