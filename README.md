# NixOS Configuration (极致 Dendritic 树突架构)

这是我的个人 NixOS 系统配置仓库，全面拥抱了最先进且最纯粹的 **Dendritic (树突) 模块化模式**。

## 核心设计理念

在这个配置中，**没有复杂的选项注册**，也没有难以理解的 `lib.mkEnableOption`。
所有的系统级配置 (`environment.systemPackages`, `services`) 和用户级配置 (`home-manager.users.maorila`) 都被**高度解耦并下放到极致**，遵循“一个软件，一个文件”的最高内聚原则。

如果你想要开启或关闭某个功能（例如 Steam 或 VSCode），只需要打开 `modules/default.nix`，通过添加或删除 `#` 注释符即可完成。当你注释掉一个模块时，与之相关的系统端口开放、后台守护进程、以及用户的专属配置都会被**连根拔起，绝无残留**。

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
└── 📂 modules                    # 极致纯血 Dendritic 特征模块库
    ├── 📄 default.nix            # 🌟 全局唯一开关控制面板
    ├── 📂 core                   # 系统核心功能
    │   ├── 📄 locale.nix         # 语言与区域
    │   └── 📄 fcitx5.nix         # 中文输入法
    ├── 📂 desktop                # 图形桌面 (高度内聚，自带必备组件)
    │   ├── 📄 gnome.nix          # GNOME 桌面环境
    │   ├── 📄 niri+noctalia.nix  # Niri 混成器环境
    │   └── 📄 lingmo.nix         # 实验性的 LingmoOS 骨架
    └── 📂 apps                   # 独立功能软件 (按软件名极致拆分)
        ├── 📄 aria2.nix
        ├── 📄 steam.nix
        ├── 📄 vscode.nix
        ├── 📄 chrome.nix
        ├── 📄 mission-center.nix
        └── ...几十个独立文件
```

## 部署与安装指南 (网络无感部署)

得益于 Nix Flakes 的能力，你可以直接从网络拉取本仓库的配置进行部署，完全不需要在本地 `git clone` 代码！

### 场景 1：日常更新与切换 (已运行的 NixOS)
在任何装有 NixOS 的机器上，直接让系统拉取远程仓库并构建，连本地残留文件都不会有。
> **💡 放心更新**：`nixos-rebuild` 和 `nh` 是绝对安全的！它们只会更新你的系统软件和配置，**绝对不会**触发 Disko 去格式化你现有的硬盘分区，你的数据稳如泰山。

```bash
# 原生方案
sudo nixos-rebuild switch --flake github:teformel/nixos-config#Laptop-maorila

# 使用内置的 nh 神器（速度更快，输出更优雅）
nh os switch github:teformel/nixos-config
```

### 场景 2：全新裸机一键装机 (使用 nixos-anywhere)
如果你买了一台全新的空电脑（或者打算彻底重装），用 NixOS 的官方 U 盘启动进入 Live 界面后，直接执行以下命令。`nixos-anywhere` 会读取配置中的 `disko-config.nix`，在几分钟内自动完成**硬盘分区、格式化、挂载并灌入整个系统**！

```bash
nix run github:nix-community/nixos-anywhere -- --flake github:teformel/nixos-config#Laptop-maorila root@localhost
```

> **🔧 备用连招（官方工具分步安装）**：如果你觉得 `nixos-anywhere` 是个黑盒，或者想在 Live U 盘下更可控地进行，也可以使用官方自带的工具连招（假设你事先拉取了配置文件）：
> ```bash
> # 1. 自动根据代码配置格式化硬盘并挂载
> sudo nix run github:nix-community/disko -- --mode disko /tmp/disko-config.nix
> # 2. 将系统安装进刚刚挂载好的硬盘中
> sudo nixos-install --flake github:teformel/nixos-config#Laptop-maorila
> ```
> 效果是完全一样的！
> **⚠️ 危险预警**：只有在使用 `nixos-anywhere`（或专门执行 disko 脚本）时，硬盘才会被真正格式化！如果你是在空机器上执行这个命令，请确保硬盘里的数据已经备份。

### 场景 3：传统的本地修改模式
如果你在本地（如 `/home/maorila/nixos-config`）修改了代码，只需要在任意位置执行：
```bash
nh os switch
```
