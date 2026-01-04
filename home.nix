{ config, pkgs, ... }:

{
  imports = [
    # === 桌面环境 ===
    ./modules/desktop/hyprland
    ./modules/desktop/waybar
    ./modules/desktop/fastfetch
    ./modules/desktop/shell
    ./modules/desktop/hyprpaper  # 壁纸
    ./modules/desktop/hyprlock   # 锁屏
    ./modules/desktop/hypridle   # 休眠
    ./modules/desktop/scripts    # 截图等脚本
    ./modules/desktop/xdg.nix    # 文件关联

    # === 常用工具 ===
    ./modules/tools/git
    ./modules/tools/vscode
  ];

  # === 用户基本信息 ===
  home.username = "maorila";
  home.homeDirectory = "/home/maorila";
  home.stateVersion = "25.11";

  # === 你的个人软件 ===
  home.packages = with pkgs; [
    # 网络与工具
    # === 代理工具 ===
    clash-verge-rev  # 现代化的 Clash GUI 客户端
    mihomo           # 强大的代理内核 (原 Clash Meta)
    (google-chrome.override {
      commandLineArgs = builtins.concatStringsSep " " [
        "--ozone-platform=x11"
        # ✨ 这里设置你想要的缩放比例
        # 如果你确实想要 "缩放为 1" (原始大小)，就填 1
        # 如果你觉得 1 太小了，可以填 1.25, 1.5 (配合你的屏幕倍率)
        # 只要这里填了参数，字就是清晰的，不会糊！
        "--force-device-scale-factor=1.5" 
      ];
    })
    qq          # 官方 Linux QQ (新版 NT 架构，体验很好)
    wechat-uos  # 官方 Linux 微信 (UOS 适配版，功能较全)

    # 系统工具
    kitty        # 终端
    wofi         # 菜单
    dunst        # 通知
    kdePackages.dolphin # 文件管理器
    # === 剪贴板工具 ===
    wl-clipboard  # 基础工具 (Wayland 剪贴板后端)
    cliphist      # 历史记录管理器
    # === 手机同步 ===
    kdePackages.kdeconnect-kde # KDE Connect 核心程序
    pavucontrol  # 必装：图形化音量控制器
    alsa-utils
    udiskie  # 自动挂载工具
    wlogout  # 关机菜单
    btop     # 任务管理器
    brightnessctl # ✨ 控制屏幕亮度的神器

    playerctl   # ✨ 媒体控制 (切歌/暂停)
    
    # 游戏与多媒体
    mangohud    # 游戏里显示 FPS/CPU 温度
    protonup-qt # 必装！用于下载 GE-Proton (解决很多游戏打不开的问题)
    # === 🎬 多媒体全家桶 ===
    mpv              # 视频播放器 (极简、高性能)
    imv              # 图片查看器 (Wayland 原生，超快)
    amberol          # 音乐播放器 (界面很美，专注听歌)
    # === 🧩 缩略图增强 (让 Dolphin 显示视频预览) ===
    ffmpegthumbnailer
    kdePackages.qtimageformats # 让 Dolphin 支持更多图片格式(如webp)
    
    # 修复与杂项
    appimage-run  # ✨ 必装：AppImage 运行器
    # 🩹 核心修复：提供 Dolphin 缺失的菜单结构文件
    gnome-menus
    # 📶 网络管理全家桶
    networkmanagerapplet  # 提供 nm-applet (托盘图标) 和 nm-connection-editor (编辑工具)
    tree  # 经典树状图工具
    eza   # 现代 ls 替代品 (支持 tree 模式)

    # === 📸 截屏工具 (脚本依赖) ===
    grim    # 核心：负责把屏幕画面抓下来
    slurp   # 核心：负责让你用鼠标画一个框
    swappy  # 核心：负责弹出一个编辑窗口，让你画箭头、保存
    psmisc
    # 自定义脚本：启动 Waybar
    (pkgs.writeShellScriptBin "start-waybar" ''
      killall .waybar-wrapped waybar 2>/dev/null
      sleep 0.3
      waybar > /dev/null 2>&1 &
    '')
    # 以后你想装 QQ、网易云、Spotify 都在这里加
    adwaita-icon-theme  # ✨ 修复 Fcitx 和系统托盘图标丢失
  ];

  # === 🖱️ 全局鼠标光标配置 (修复 Gdk-Message 报错) ===
  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Ice";
    size = 24;
  };

  # === 关键：让 Home Manager 接管字体配置 ===
  # 这能解决部分软件在用户级安装后字体发虚、锯齿的问题
  fonts.fontconfig.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # === ⌨️ 强制修复 Fcitx5 输入法界面太小 ===
  # 直接生成配置文件，强制设置大字体
  home.file.".config/fcitx5/conf/classicui.conf".text = ''
    # 垂直列表 (选词更符合直觉)
    Vertical Candidate List=False
    
    # 按屏幕 DPI 缩放 (如果这个不管用，下面的 Font 会兜底)
    PerScreenDPI=True
    
    # ✨ 核心修复：强制设置一个大字体
    # "字体名 字号"，比如这里设为 16 或 18 (默认通常是 10，太小了)
    Font="JetBrains Mono 16"
    
    # 主题设置 (你可以选个喜欢的主题，或者用默认)
    Theme=default
  '';

  # 让 Home Manager 管理自己
  programs.home-manager.enable = true;
}

