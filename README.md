# NixOS Configuration (GNOME 专属大一统分支)

这是我的个人 NixOS 系统配置仓库的 **`gnome` 分支**。在这个平行宇宙中，没有任何其他干扰项，它提供了最稳定、最纯粹的 **GNOME (Wayland)** 桌面生态体验。

## 🌟 系统组件 (GNOME Ecosystem)

| 🧩 组件类别 | 🛠️ 当前选择 |
| :--- | :--- |
| **窗口与显示管理器** | Mutter / GDM |
| **桌面交互环境** | GNOME Shell |
| **终端环境** | GNOME Terminal / Ptyxis / Ghostty |
| **文本编辑器** | GNOME Text Editor & VSCode |
| **色彩主题** | GNOME Adwaita (原生) |
| **系统字体** | Noto-fonts & FiraCode Nerd Font |
| **本地媒体播放** | GNOME Videos / mpv |
| **文件管理器** | Nautilus (GNOME Files) |
| **截屏与录屏** | GNOME 原生截屏系统 (Print Screen) |
| **中文输入法** | Fcitx5 + Rime (雾凇拼音) |
| **底层网络管理** | NetworkManager |
| **系统引导与管家**| systemd-boot & systemd |
| **包管理器** | Nix (Flakes + nh) |


## 📁 目录结构解析

在这个架构下，系统变得极其直观，你不需要再迷失在几十个文件夹里：

```text
nixos-config/
├── flake.nix                  # Flake 极简入口点
├── flake.lock
├── README.md                  # 本说明文档
├── 📂 flake-modules           # Flake 级别的高阶模块化构件
├── 📂 hosts                   # 主机配置入口
│   └── 📂 laptop-maorila      # 机器名：Laptop-maorila
│       ├── 📄 default.nix     # 🖥️ 核心系统配置（内核、网络、Nix源、用户权限）
│       ├── 📄 hardware-*      # 硬件与驱动相关
│       └── 📄 disko-config.nix# 硬盘分区规划
└── 📂 modules                 # 模块库
    ├── 📄 default.nix         # 🔌 全局唯一开关控制面板
    ├── 📄 apps.nix            # 📦 所有日常应用软件的清单列表
    └── 📄 desktop.nix         # 🎨 GNOME 专属桌面环境配置
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

### 场景 3：传统的本地修改模式
如果你在本地修改了代码（比如直接编辑了 `modules/apps.nix` 加入了新软件），只需要在任意位置执行：
```bash
nh os switch
```
