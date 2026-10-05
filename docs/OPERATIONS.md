# 重新编译、升级与设备测试

## 构建

Ruby/YAML 解释器保留供 OpenClash 使用，仅关闭可选 YJIT，避免该功能继续引入 Rust host。配置预检按实际启用条件核对 Rust 构建依赖，packageinfo.gz 保存完整元数据。

1. 在 GitHub Actions 打开 `Athena VIKINGYFY`，勾选 preview 运行预检。
2. 确认两个预检任务都成功，下载 `athena-b-config-firmware-*`；检查 `preflight.txt`、`protected.diff`（应为空）、`application.diff`、`final.config`、空的 `selected-rust-consumers.txt` 和 `checkpoint-restore-firmware.txt`。预检仅解析配置并验证源树跨任务恢复，不编译或发布。
3. 保持同一套已通过预检的源锁与配置，取消 preview 运行正式编译。先完成工具/工具链/内核，再编译其余软件包并打包固件；两个任务串行，每个编译阶段最多四小时，留出运行器准备、检查点恢复和诊断上传时间。PassWall 1/2 及专用核心已移除，不执行独立 Rust 编译。正式编译先执行配置预检，后续任务恢复同一次运行的源树、验证源码/输入/配置哈希及底层保护证据，不重复改写应用配置。每个产物记录实际框架提交；配置或锁文件更新后必须重新预检。
4. 成功后从 `athena-b-*` Release 下载雅典娜 Factory/Sysupgrade 和 SHA256SUMS，以及配置、manifest 和 packages。
5. 要重建相同源配置，检出该 Release 记录的框架提交，并保持 `build.lock.tsv`。升级上游时先更新自己的框架/源码/feeds/插件锁，重新预检，不能直接切换到其他作者源码。

中间检查点为 `athena-b-checkpoint-toolchain-*`，仅保留三天。tar.zst 保存完整工作树、工具、安装目录、下载缓存及构建 stamps，保留软链接/权限/时间；SHA-256、输入指纹、源码提交和最终配置哈希均需匹配。预检检查点不能用于正式构建，含 PassWall 的旧 Run 检查点也不能用于本轮。签名材料不传递，在最终任务重新生成。

后续阶段失败时，在同一个 Run 使用 GitHub 的 **Re-run failed jobs**，可从已成功阶段的检查点恢复；只要检查点仍未过期，不需要重编前面的成功阶段。检查点过期或变更构建输入后，需要启动新的完整 Run。原先仅在整轮成功后保存 staging_dir 的缓存策略已由阶段检查点替代。

工具链阶段达到四小时软限制时，会在编译进程退出且配置哈希仍一致后保存未完成检查点，任务仍标记失败。重跑该失败任务会优先恢复自身检查点；未完成检查点仅限工具链阶段使用，最终固件任务拒绝消费它。普通编译错误和配置变化不保存这种检查点。最终固件阶段失败时从已完成的工具链检查点重跑，不传递中途生成的签名材料。

此轮保留作者默认地址 192.168.10.1、SSID OWRT、示例无线密码 12345678、初始 root 无密码。接入日常网络前设置自己的管理和无线密码。

## 手动升级

在刷机电脑核对下载文件 SHA-256。使用适合当前设备安装状态的镜像：已运行兼容 OpenWrt 时通常用 sysupgrade；Factory 仅用于对应引导器支持的初装/恢复路径。此项目不会自动连接路由器或执行刷机。

不要使用 Attended Sysupgrade 重新生成固件。每次升级使用本仓库 Actions 重新编译的镜像。若保留旧配置，固件的首次启动脚本仍会关闭 OpenClash 和 Docker，先确认服务状态再测试。

## 验证顺序

首次启动确认 OpenClash、Docker 关闭，然后按 `REQUIREMENTS.md` 的当前生效要求完成有线 IPv4/IPv6、千兆上下行、NSS/CPU负载、Wi-Fi 80MHz、Wi-Fi 160MHz 长时间与多设备测试。记录终端、频宽、测试时长、吞吐、断流和日志，再测试服务。

OpenClash：导入自己的配置，启用服务；核查国内站点、Google/ChatGPT/Gemini、日本节点/AI分组、DNS/IPv6。订阅和密钥不得提交 Git。

固件不包含 PassWall 1/2，无备用代理切换步骤。

最后启用 Docker：配置持久化存储路径，运行 dockerd，检查 bridge、DNS、NSS/Firewall、内存和日志。不要为了 Docker 修改 NSS、无线或作者的 Firewall 核心实现。

首次关闭只控制默认状态，不替代用户启用服务前的检查。
