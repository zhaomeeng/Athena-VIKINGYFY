# B版来源与应用调整

检查日期：2026-10-05（Asia/Shanghai）。

- 编译框架：VIKINGYFY/OpenWRT-CI，提交 `cdff7eb66975f7657937a09becb2bf11cef85c34`。
- 源码：VIKINGYFY/immortalwrt，main，提交 `0fb9b10cb9df51fb076470e1dd93d1c30dd89d83`。
- 对应上游发布：`IPQ60XX-WIFI-YES-VIKINGYFY-main-26.10.04-07.58.53`，内核 6.18.52。
- 原始 `Config/IPQ60XX-WIFI-YES.txt`、`Config/GENERAL.txt`、`Scripts/Handles.sh`、`Scripts/Settings.sh` 保留。
- 设备定义包含 `jdcloud_re-cs-02`、QCN9074 DDWRT 固件和 Athena LED。QCN9074 在全局配置中为 `m`，由设备默认软件包装入雅典娜镜像；不能用全平台 manifest 缺少该条目判定雅典娜缺少固件。

## 应用差异

删除 HomeProxy、GecoosAC、NATMapT 及后两者的运行包；新增 OpenClash、PassWall2、Lucky、TTYD、Docker/dockerd、Dockerman。PassWall2 选择 nftables 透明代理及 Xray/Sing-box 双核心，具体依赖由当前包的 Kconfig 解析。

保留作者 FullCone NAT Sonic、UPnP、WOL Ultra、Mini Disk Manager、Samba4、Partexp、AutoReboot、Firewall、Package Manager、Aurora Theme/Config。

`Config/ATHENA-APPS.txt` 是唯一应用选择层。`build.lock.tsv` 固定源码、feeds、原脚本全部第三方仓库和新增 Lucky、Mihomo。此轮先使用作者现有插件获取方式，未启用的插件源码仍可能被拉取；是否进入固件由最终配置和 manifest 判断。

## 构建流程差异

- 上游其他平台与清理工作流移至 `docs/upstream-workflows/` 存档，避免新仓库自动批量构建或自动清除发布记录。
- 只启用手动 `Athena VIKINGYFY` 工作流；默认运行配置预检。
- 使用原 WRT-CORE 的环境、feeds、插件、设置和编译顺序，加入锁定、配置对比和交付检查。
- 上游初始化仍使用其公开环境安装脚本；提交锁定保证源配置复现，不承诺不同构建时间产生逐字节一致的镜像。
- 不调用原先删除 packages/buildinfo 后打包的方法。保存最终配置、作者基线、应用差异、受保护配置差异、锁文件、实际 feed 提交、源码变更摘要、Factory/Sysupgrade、manifest、packages、buildinfo、profiles.json、SHA256SUMS。
- 预检运行只上传配置证据，不生成固件 Release。
- 首次启动关闭两个代理和 dockerd；OpenClash 核心来自 MetaCubeX/mihomo v1.19.32，经 SHA-256 核验。

## 验证边界

预检证明 Kconfig 解析及配置保护条件。完整编译证明软件包和镜像能够构建。160MHz 稳定性、NSS 实际加速、Docker bridge 与 Firewall/NSS 共存必须通过实机测试，不能由云编译结论替代。
