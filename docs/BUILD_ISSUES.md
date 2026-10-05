# 构建问题与处理记录

2026-10-05：

- 当前 Windows 无可用 WSL 发行版。使用 Git for Windows 的 Bash 进行本地语法检查，真实 defconfig/构建由 GitHub Ubuntu Actions 执行；没有安装额外系统环境。
- 新建仓库推送后，GitHub 一度未注册工作流，dispatch 返回 404。已通过 API 验证工作流存在；加入只执行预检的工作流文件 push 触发后注册成功，预检 Run `37241333236` 启动。该问题不是软件包/底层编译错误。
- 上游全平台 manifest 不包含全部设备专用包。QCN9074 在配置中为 m、在雅典娜设备定义中启用，因此新增 Factory squashfs 文件内容检查，以确认实际雅典娜镜像的双无线固件、代理核心、Docker 和默认关闭脚本。
- 从实际源码核对 host 工具名称为 `unsquashfs4`，IPQ6018 DDWRT 固件目录为 `/lib/firmware/IPQ6018`；打包检查采用对应工具和目录。

## 首次正式编译失败：runner 磁盘耗尽

Run `37241920846` 于 2026-10-05 08:25:32（Asia/Shanghai）结束，结论 failure。GitHub check-run `111552187381` 的 failure 注释确认 `System.IO.IOException: No space left on device`，runner 无法继续写诊断日志。

Custom Settings/预检、Save configuration evidence、Download Packages 均成功。正式运行配置 artifact 已下载，preflight PASS，protected.diff 为 0 字节。Compile Firmware 在 runner 异常退出时仍显示 in_progress；后续打包与发布未执行。没有固件或 Release。完整 job 日志返回 `log not found`，因此没有可据以判断的具体包编译错误。

下一步优化构建环境磁盘使用，再使用相同源锁和应用配置重编。本次状态检查仅记录证据，没有修改构建流程或触发重编。

## 磁盘修复与第二次构建准备

从成功预检 Run `37241333236` 的完整日志核对，runner 为 Ubuntu 24.04，根盘 72G、已用 62G、剩余约 11G；`/mnt/build_wrt` 与根盘共用文件系统。仅把构建树放到 `/mnt` 无法扩大容量。

这次只调整构建环境和临时文件策略：

- 固定 `ubuntu-24.04`，保持首次预检的系统系列。
- 在安装构建依赖前，清理临时 runner 的 Android、.NET、GHC、Swift、hosted tool cache 与闲置 Docker 镜像；保留 runner/action runtime 和系统工具。
- 使用已锁源码 `include/package.mk` 提供的 `CONFIG_AUTOREMOVE=y` make 参数，清理已完成软件包的编译目录，保留 `.pkgdir` 和构建 stamps；不写入最终 `.config`。
- 将 ccache 上限设为 1G。编译前要求至少 20 GiB 空间，每分钟检查 root/build 文件系统；低于 3 GiB 时停止编译进程组，保留日志和诊断空间。
- 上传环境清理前后、依赖下载后、编译前后及每分钟磁盘记录；检查编译前后 `.config` 哈希相同。

版本锁、IPQ60XX-WIFI-YES、GENERAL、应用 overlay 和作者底层脚本均未修改。B 版重编仍先执行完整配置预检。清理效果和最终编译结果以第二次实际运行的 artifact 为准。

第二次 Run 37253202265 实测：72G 根盘清理前可用 14G、清理后 45G、依赖安装后 42G。新配置预检再次通过，protected.diff 为 0 字节，最终配置 SHA-256 与 Run 37241920846 完全相同。

## 第二次正式构建取消：超过 6 小时任务上限

Run `37253202265` 于 2026-10-05 09:53:36 创建、15:53:59 结束（Asia/Shanghai），结论 cancelled。check-run `111584892006` 明确记录：`The job has exceeded the maximum execution time of 6h0m0s`。Compile Firmware 从 10:06:54 执行到 15:53:53，尚在软件包编译阶段；打包、固件 artifact、Release 均被跳过。

已下载完整日志和 `athena-b-diagnostics-37253202265`。347 条空间记录中最低可用 21003656 KiB（约 20.0 GiB），最后一条 15:53:04 为 21655416 KiB（约 20.7 GiB）；没有 disk-stop.txt，磁盘低空间保护未触发。编译日志未见 make Error 或包编译 ERROR，超时前仍有 nftables 编译输出，不能判定固件编译成功。defconfig 阶段另有依赖递归诊断，必需应用/排除项和底层保护预检实际 PASS。

Restore Build Cache 没有命中；超时后 Save Build Cache 被跳过，本轮成果不能据此视为可供下轮恢复的构建缓存。取消时缺少 compile-space-after.txt 和 compile-config-after.sha256，编译前后配置一致检查尚未完成。

下一步处理完整构建时长和可恢复缓存；仍保留原源码锁、应用配置与作者底层基线。本次状态检查未修改构建脚本、工作流或触发第三次构建。

## 分阶段构建与恢复准备

用户授权继续后核对日志：10:06:54 开始编译，11:30:19 进入内核编译，12:14:20 进入软件包编译；Rust host-compile 从 12:36:00 开始，取消时还有 Rust bootstrap/LLVM 编译进程。GitHub 托管 runner 单任务上限为六小时，增加 timeout-minutes 不能扩展这个上限（[官方限制](https://docs.github.com/en/actions/reference/limits)）。

- 工具/工具链/内核、Rust 主机编译器、最终固件拆成三个串行任务，各段编译最多五小时，留出诊断上传时间。
- 使用原生 `tools/install`、`toolchain/install`、`target/compile`、`package/feeds/packages/rust/host/compile` 目标；不改 Rust 包、NSS、内核或应用选择。
- 传递完整工作树，保持 `/mnt/build_wrt` 路径和文件时间，避免只恢复 staging_dir 而丢失 build_dir 内的 .prepared/.configured/.built stamps。已锁源码的 host-build.mk 在 AUTOREMOVE 下仍保留零字节 stamps，原生 host-compile 已完成的目录内容会清理。
- 检查点用 tar.zst 保存软链接、权限和隐藏文件，校验源锁、构建输入、最终配置、平台、同一次 Run 以及 SHA-256；不传递根目录签名材料，不将凭证配置收入检查点。中间 artifact 保留三天，后续失败可在同一次 Run 重跑失败任务。
- 默认 preview 先实际运行源树打包和两次跨任务恢复，不编译；通过后再启动正式构建。静态 Bash 语法和 actionlint 已通过；实际恢复结果待预检。
- Rust 本段若仍触及五小时软限制，保存未完成检查点，重跑失败任务可继续其 host-compile。只接受限时退出码 124 且编译前后配置一致；最终固件阶段只接受完成标志为 true 的检查点。该限时续编路径尚待真实构建验证。
- ShellCheck v0.11.0 检查新增脚本与工作流内联 Bash：修正原工作流路径引用的引号，标明子 Bash 展开和 trap 回调两项静态分析例外；完整检查通过。恢复证据时另存当前 runner 的空间记录，避免被上一段证据覆盖。这些修正不改变源码、版本锁或最终固件配置。
