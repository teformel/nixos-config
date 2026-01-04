{ config, pkgs, lib, ... }:

{
  imports = [
    # === 🖥️ 桌面环境 (Desktop Environment) ===
    ./modules/desktop/hyprland
    ./modules/desktop/waybar
    ./modules/desktop/hyprpaper
    ./modules/desktop/hyprlock
    ./modules/desktop/hypridle
    ./modules/desktop/fcitx5
    ./modules/desktop/screenshot  # ✨ 改名了：这里很清楚它是负责截图的
    ./modules/desktop/xdg.nix

# === 📦 常用软件 (Programs) ===
    ./modules/programs/git        # ✨ 路径变了
    ./modules/programs/vscode     # ✨ 路径变了
    ./modules/programs/fastfetch  # ✨ 归类到这里了
    ./modules/programs/shell      # ✨ 归类到这里了
    # ./modules/programs/antigravity
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

    # 以后你想装 QQ、网易云、Spotify 都在这里加
    adwaita-icon-theme  # ✨ 修复 Fcitx 和系统托盘图标丢失
    seahorse # GUI 密钥管理器
  ];

  # === 🖱️ 全局鼠标光标配置 (修复 Gdk-Message 报错) ===
  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Ice";
    size = 24;
  };

  # 2. 第二步：激进清理 (Activation Script)
  # 在新配置写入完成后，立即把刚才生成的 .backup 文件全删了
  home.activation.removeExisting = lib.hm.dag.entryAfter ["writeBoundary"] ''
    # ⚠️ 警告：这会删除目录下所有后缀为 .backup 的文件
    # 请确保你没有重要文件正好叫这个后缀
    
    echo "🧹 [激进模式] 正在清理冲突文件的备份..."
    
    # 清理 .config 下的备份
    find ${config.home.homeDirectory}/.config -name "*.backup" -type f -delete
    
    # 清理 Fcitx5 相关的特定备份 (针对你刚才的问题)
    rm -f ${config.home.homeDirectory}/.config/fcitx5/conf/classicui.conf.backup
    
    # 如果你想更狠一点，清理家目录下所有的 (慎用!)
    find ${config.home.homeDirectory} -maxdepth 2 -name "*.backup" -type f -delete
  '';

  # === 关键：让 Home Manager 接管字体配置 ===
  # 这能解决部分软件在用户级安装后字体发虚、锯齿的问题
  fonts.fontconfig.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # 让 Home Manager 管理自己
  programs.home-manager.enable = true;
}

