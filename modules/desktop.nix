# modules/desktop.nix
{ config, pkgs, inputs, ... }:

{
  # 1. 开启 Niri 混成器
  programs.niri.enable = true;

  # 2. 显示管理器
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  # 字体配置
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    wqy_microhei
    wqy_zenhei
    nerd-fonts.fira-code  # 最受程序员欢迎的连字代码字体 FiraCode 的 Nerd 版
    nerd-fonts.meslo-lg   # 另一个非常好看的终端字体
  ];

  # 外观与 Qt 配置
  # 1. 开启 dconf（在独立窗口管理器中，这是保存和读取图标主题必须的核心）
  programs.dconf.enable = true;
  # 🚀 [新增] 启用 Qt 模块并指定配置工具
  qt = {
    enable = true;
    # 指定使用 qt5ct/qt6ct 作为 Qt 程序的全局主题管理器
    platformTheme = "qt5ct"; 
  };

  # Install firefox.
  programs.firefox.enable = false;

  # 6. XDG 门户机制 (对于屏幕共享和文件选择框是刚需)
  xdg.portal = {
    enable = true;
    # Niri 环境下通常推荐 xdg-desktop-portal-gnome 或 gtk 来提供配置读取接口
    extraPortals = with pkgs; [ 
      xdg-desktop-portal-gnome # Niri 录屏强制依赖此项
      xdg-desktop-portal-gtk 
    ];
    config.common.default = "*"; # 允许所有请求
    config.niri = {
      default = [ "gtk" "gnome" ];
    };
  };

  # 文件管理器
  # 🗂️ 文件管理与自动挂载
  # 1. 开启 Thunar 文件管理器及其插件模块（不要只写在 systemPackages 里）
  programs.thunar = {
    enable = true;
    plugins = with pkgs.xfce; [
      thunar-archive-plugin # 压缩包支持
      thunar-volman         # U 盘/外部存储管理支持
    ];
  };

  # === 基础服务 ===
  services.gvfs.enable = true;
  services.udisks2.enable = true;

  # UI 相关的包
  environment.systemPackages = with pkgs; [
    glib                       # 提供 gsettings 命令
    gsettings-desktop-schemas  # 提供核心架构
    # 从 flake inputs 中安装 Noctalia
    inputs.noctalia.packages.${pkgs.system}.default    
    alacritty          # Niri 默认绑定的终端
    ghostty
    wl-clipboard       # Wayland 剪贴板支持
    xwayland-satellite # XWayland 兼容支持
    papirus-icon-theme # 极其强大的标准图标库
    nwg-look           # 🚀 [新增] 专门用于 Wayland 的外观设置工具
    # 安装 Qt 主题设置工具（因为最新的 Fcitx5 已经全面迁移到 Qt6）
    kdePackages.qt6ct 
    libsForQt5.qt5ct  # 顺手兼容旧版的 Qt5 软件
    udiskie       # U 盘自动挂载守护进程
    file-roller   # 配合 Thunar 使用的压缩/解压后端
    vscode
    #pkgs.ungoogled-chromium
    pkgs.google-chrome
    pkgs.mission-center
  ];
}
