# 构建问题与处理记录

2026-10-05：

- 当前 Windows 无可用 WSL 发行版。使用 Git for Windows 的 Bash 进行本地语法检查，真实 defconfig/构建由 GitHub Ubuntu Actions 执行；没有安装额外系统环境。
- 新建仓库推送后，GitHub 一度未注册工作流，dispatch 返回 404。已通过 API 验证工作流存在；加入只执行预检的工作流文件 push 触发后注册成功，预检 Run `37241333236` 启动。该问题不是软件包/底层编译错误。
- 上游全平台 manifest 不包含全部设备专用包。QCN9074 在配置中为 m、在雅典娜设备定义中启用，因此新增 Factory squashfs 文件内容检查，以确认实际雅典娜镜像的双无线固件、代理核心、Docker 和默认关闭脚本。
- 从实际源码核对 host 工具名称为 `unsquashfs4`，IPQ6018 DDWRT 固件目录为 `/lib/firmware/IPQ6018`；打包检查采用对应工具和目录。

尚无完整编译结论；普通依赖错误待预检或编译实际发生后记录。
