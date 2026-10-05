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
