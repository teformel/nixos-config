# NixOS Configuration (大一统多主机架构)

这是我的个人 NixOS 系统配置仓库，采用了极简、强大的 **多主机 (Multi-Host) 架构** 与 **多桌面平行宇宙**。

## 🌟 系统组件全矩阵 (System Components Matrix)

由于 `master` 主干分支包含了本仓库所有的桌面配置，你可以利用它直接切换和部署出不同形态的桌面宇宙！以下是当前支持的核心桌面维度展示：

| 🧩 组件类别 | 🖥️ GNOME (生产力) | ⌨️ Niri (极客平铺) | ✨ Lingmo (源码实验) |
| :--- | :--- | :--- | :--- |
| **窗口显示器** | Mutter / GDM | Niri (滚动平铺) | KWin (Wayland) |
| **交互环境** | GNOME Shell | Noctalia Shell | Lingmo OS UI |
| **终端** | Ptyxis / Ghostty | Alacritty + Fish | Alacritty / Ghostty |
| **编辑器** | VSCode & Neovim | Neovim & VSCode | Neovim & VSCode |
| **应用启动** | GNOME 搜索 | Fuzzel | Lingmo 启动器 |
| **中文输入** | Fcitx5 + 雾凇拼音 | Fcitx5 + 雾凇拼音 | Fcitx5 + 雾凇拼音 |
| **文件管理** | Nautilus | Yazi & Thunar | Yazi & Thunar |
| **色彩主题** | Adwaita | Catppuccin Mocha | - |

> **提示**：除了上述三大主力桌面，`virtual-maorila` 虚拟机还搭载了极致轻量的 **LXQt / i3wm / IceWM**！

## 📁 多主机目录结构解析 (Multi-Host Architecture)

在现在的架构下，系统既能管理多台实体机器（真机与虚拟机），又能统筹切换多个桌面环境：

```text
nixos-config/
├── flake.nix                  # Flake 极简入口点 (统筹全部机器)
├── flake.lock
├── README.md                  # 本说明文档
├── 📂 flake-modules           # Flake 级别的高阶模块化构件
├── 📂 hosts                   # 多主机配置入口
│   ├── 📂 laptop-maorila      # 💻 你的物理真机
│   │   ├── 📄 default.nix     # 🖥️ 真机系统配置
│   │   └── 📄 disko-config.nix# 硬盘分区规划
│   │
│   └── 📂 virtual-maorila     # 🖥️ 你的轻量级虚拟机 (LXQt/i3wm)
│       ├── 📄 default.nix     # 虚拟机系统配置
│       ├── 📄 home.nix        # 虚拟机专属用户配置
│       └── 📄 disko-config.nix
│
└── 📂 modules                 # 公共模块库 (可供所有机器复用)
    ├── 📄 default.nix         # 🔌 桌面/功能总开关
    ├── 📄 apps.nix            # 📦 所有日常应用软件的清单列表
    └── 📂 desktop             # 🎨 桌面环境方案池
        ├── 📄 gnome.nix
        ├── 📄 niri+noctalia.nix
        └── 📄 lingmo.nix
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

### 场景 4：使用 Disko 手动分区与装机 (备用装机方案)
如果在裸机上遇到网络环境复杂导致 `nixos-anywhere` 报错，或者你希望亲自观察分区与装机的每一步，你可以直接使用 Disko 脚本进行传统的两步走安装：

```bash
# 1. 自动执行硬盘打火与分区挂载 (以真机 Laptop-maorila 为例)
# 它会读取 disko-config.nix 自动执行 fdisk/mkfs/mount 等操作到 /mnt
sudo nix run github:nix-community/disko -- --mode disko --flake github:teformel/nixos-config#Laptop-maorila

# 2. 将系统正式灌入硬盘 (不需要加 --no-root-passwd)
sudo nixos-install --flake github:teformel/nixos-config#Laptop-maorila
```
