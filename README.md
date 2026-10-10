# 高质量<免费>交流群

本仓库维护京东云雅典娜 B 版：VIKINGYFY 原生 IPQ60XX-WIFI-YES + ImmortalWrt。仓库公开，固件保留 OpenClash，额外加入 PassWall2（Xray/Sing-box，nftables），不包含 PassWall 1 或 Shadowsocks Rust。首次启动两套代理及 Docker 均关闭，代理按需切换。手动入口为 **Athena VIKINGYFY**，先 preview 再编译；状态见 [开发状态](docs/DEVELOPMENT_STATUS.md)，构建与升级见 [操作说明](docs/OPERATIONS.md)。以下保留作者通用说明。

[IPQ技术讨论群](https://qm.qq.com/q/v7nMhzB4oU)

# 高质量<付费>中转站

[LiBwrt-Ai](https://api.zipimg.cn/register?aff=LR7FSZ2ZZ4D3)

# 本地编译器

https://github.com/VIKINGYFY/OWRT-Tools.git

# 自用修改版插件

https://github.com/VIKINGYFY/packages.git

# OpenWRT-CI

官方版：

https://github.com/immortalwrt/immortalwrt.git

自用版：

https://github.com/VIKINGYFY/immortalwrt.git

# U-BOOT

高通版-沉心：

https://github.com/chenxin527/uboot-qsdk12.5-build.git

高通版-小猪：

https://github.com/1980490718/u-boot-2016.git

联发科-全新版：

https://github.com/VIKINGYFY/UBOOT-CI/releases

联发科-官方版：

https://drive.wrt.moe/uboot/mediatek

# 固件简要说明

固件每天早上5点自动编译。

固件信息里的时间为编译开始的时间，方便核对上游源码提交时间。

MEDIATEK系列、QUALCOMMAX系列、ROCKCHIP系列、X86系列。

# 目录简要说明

workflows——自定义CI配置

Scripts——自定义脚本

Config——自定义配置

#
[![Stargazers over time](https://starchart.cc/VIKINGYFY/OpenWRT-CI.svg?variant=adaptive)](https://starchart.cc/VIKINGYFY/OpenWRT-CI)
