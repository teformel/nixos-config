# NixOS Configuration (纯血 Dendritic 树突架构)

这是我的个人 NixOS 系统配置仓库，全面拥抱了最先进的 **Dendritic (树突) 模块化模式**。

## 核心设计理念

在这个配置中，**没有 `users` 目录**，也没有独立的 `home.nix`。
所有的系统级配置 (`environment.systemPackages`, `services`) 和用户级配置 (`home-manager.users.maorila`) 都被**高内聚**地写在同一个功能模块文件中。

如果你想要移除某个功能（例如 Aria2），只需要删除 `modules/apps/downloader.nix`，与之相关的系统端口开放、后台守护进程、以及用户的专属下载配置都会被**连根拔起，绝无残留**。

## 目录结构解析

```text
📦 nixos-config
├── 📄 flake.nix                  # Flake 极简入口点
├── 📄 flake.lock
├── 📄 README.md                  # 本说明文档
├── 📂 flake-modules              # Flake 级别的高阶模块化构件
│   ├── 📄 nixos.nix              # 组装 nixosConfigurations
│   ├── 📄 formatter.nix          # 定义代码格式化工具 (nix fmt)
│   └── 📄 devshells.nix          # 定义开发环境 (nix develop)
├── 📂 hosts                      # 主机配置入口
│   └── 📂 laptop-maorila         # 机器名：Laptop-maorila
│       ├── 📄 default.nix        # 主配置文件
│       ├── 📄 hardware-configuration.nix 
│       ├── 📄 hardware-quirks.nix# 特定机器的硬件调优
│       └── 📄 disko-config.nix   # 硬盘分区规划
└── 📂 modules                    # 纯血 Dendritic 特征模块库
    ├── 📂 core                   # 系统核心功能
    │   ├── 📄 i18n.nix           # 语言与输入法
    │   └── 📄 cli.nix            # 终端环境 (Fish, Git, Bottom, 环境变量)
    ├── 📂 desktop                # 图形桌面
    │   ├── 📄 niri+noctalia.nix  # Niri 混成器环境
    │   └── 📄 lingmo.nix         # 实验性的 LingmoOS
    └── 📂 apps                   # 独立功能软件
        ├── 📄 gaming.nix         # 游戏栈
        ├── 📄 virt.nix           # 虚拟化栈
        ├── 📄 media.nix          # OBS, 音乐播放器等
        └── 📄 downloader.nix     # Aria2 等下载器
```

## 部署说明

1. 确保本配置文件夹位于：`/home/maorila/nixos-config`。
2. 首次部署使用：`sudo nixos-rebuild switch --flake .#Laptop-maorila`
3. 日常更新与一键构建：由于内置了环境变量和 `nh` 工具，你可以在任意目录下直接运行 `nh os switch`。
