# 重新编译、升级与设备测试

## 构建

1. 在 GitHub Actions 打开 `Athena VIKINGYFY`，勾选 preview 运行预检。
2. 确认运行成功，下载 `athena-b-config-*`；检查 `preflight.txt`、`protected.diff`（应为空）、`application.diff`、`final.config`。
3. 使用同一仓库提交，取消 preview 运行正式编译。正式编译会再次执行同样的预检，失败即停止。
4. 成功后从 `athena-b-*` Release 下载雅典娜 Factory/Sysupgrade 和 SHA256SUMS，以及配置、manifest 和 packages。
5. 要重建相同源配置，检出该 Release 记录的框架提交，并保持 `build.lock.tsv`。升级上游时先更新自己的框架/源码/feeds/插件锁，重新预检，不能直接切换到其他作者源码。

此轮保留作者默认地址 192.168.10.1、SSID OWRT、示例无线密码 12345678、初始 root 无密码。接入日常网络前设置自己的管理和无线密码。

## 手动升级

在刷机电脑核对下载文件 SHA-256。使用适合当前设备安装状态的镜像：已运行兼容 OpenWrt 时通常用 sysupgrade；Factory 仅用于对应引导器支持的初装/恢复路径。此项目不会自动连接路由器或执行刷机。

不要使用 Attended Sysupgrade 重新生成固件。每次升级使用本仓库 Actions 重新编译的镜像。若保留旧配置，固件的首次启动脚本仍会关闭两个代理和 Docker，先确认服务状态再测试。

## 验证顺序

首次启动确认 OpenClash、PassWall2、Docker 关闭，然后按 `REQUIREMENTS.md` 完成有线 IPv4/IPv6、千兆上下行、NSS/CPU负载、Wi-Fi 80MHz、Wi-Fi 160MHz 长时间与多设备测试。记录终端、频宽、测试时长、吞吐、断流和日志，再测试服务。

OpenClash 主用：停止并禁用 PassWall2，导入自己的配置，启用 OpenClash；核查国内站点、Google/ChatGPT/Gemini、日本节点/AI分组、DNS/IPv6。订阅和密钥不得提交 Git。

PassWall2 备用：先停止并禁用 OpenClash，再启用 PassWall2；验证 TCP/UDP、DNS、Xray/Sing-box 和透明代理。测试后停止 PassWall2，再恢复 OpenClash。

最后启用 Docker：配置持久化存储路径，运行 dockerd，检查 bridge、DNS、NSS/Firewall、内存和日志。不要为了 Docker 修改 NSS、无线或作者的 Firewall 核心实现。

两套代理可以共存安装，但每次只能启用一套。首次关闭只控制默认状态，不替代用户手动切换时的服务检查。
