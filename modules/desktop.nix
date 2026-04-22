# modules/desktop.nix
{ config, pkgs, inputs, ... }:

{
  # === 桌面环境与显示管理器 ===
  # 1. 恢复并启用 SDDM
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true; # 开启 SDDM 的纯 Wayland 模式，抛弃 X11 依赖
    # 🌟 指定主题文件夹的名称 sddm-astronaut-theme (宇航员) 主题
    theme = "sddm-catppuccin-mocha"; 
    # 如果你想用 Catppuccin，这里可以写 "catppuccin-mocha"
  };

  # 2. 保持 Niri 混成器为主力
  programs.niri.enable = true;

  # === 字体配置 ===
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    wqy_microhei
    wqy_zenhei
    nerd-fonts.fira-code  
    nerd-fonts.meslo-lg   
  ];

  # === 外观与基础配置 ===
  # 开启 dconf (虽然删了 GNOME，但许多 GTK 应用和 Niri 的某些底层行为仍依赖 dconf)
  programs.dconf.enable = true;
  
  qt = {
    enable = true;
    platformTheme = "qt5ct"; 
  };

  programs.firefox.enable = false;

  # === XDG 门户机制 ===
  xdg.portal = {
    enable = true;
    # 移除了 GNOME 专属的 portal，换成更通用的 wlr，保障 Niri 下的录屏和截图
    extraPortals = with pkgs; [ 
      xdg-desktop-portal-gtk 
      xdg-desktop-portal-wlr
    ];
    config.common.default = "*"; 
  };

  # === 文件管理器 ===
  # GNOME 的 Nautilus 被干掉了，Thunar 正式上位成为主力
  programs.thunar = {
    enable = true;
    plugins = with pkgs; [
      thunar-archive-plugin 
      thunar-volman         
    ];
  };

  # === 基础服务 ===
  # Thunar 极度依赖 gvfs 和 udisks2 来实现垃圾篓、U盘自动挂载等功能，必须保留
  services.gvfs.enable = true;
  services.udisks2.enable = true;

  # === 系统包 ===
  environment.systemPackages = with pkgs; [
    glib                       
    gsettings-desktop-schemas  
    inputs.noctalia.packages.${pkgs.system}.default    
    ghostty
    wl-clipboard       
    xwayland-satellite 
    papirus-icon-theme 
    
    # 🌟 恢复 nwg-look！脱离了 GNOME Tweaks，你需要它来修改 GTK 主题、图标和鼠标指针
    nwg-look           
    
    kdePackages.qt6ct 
    libsForQt5.qt5ct  
    udiskie       
    file-roller   
    vscode
    google-chrome
    mission-center
    localsend
    
    # 🚨 删除了 gnome-tweaks 和下面那一大坨 GNOME 游戏/全家桶的屏蔽代码
    #antigravity-fhs

    # 🌟 1. 引入主题包（二选一即可）
    #sddm-astronaut      # 极具科幻感的深空主题
    catppuccin-sddm   # 时下最流行的柔和暗色主题

    # 🚨 2. 防白屏终极指南（非常关键）
    # 在 NixOS 中，许多高级 SDDM 主题使用了额外的 Qt 渲染特效。
    # 因为 Unstable 版本的 SDDM 已经默认迁移到 Qt6，我们必须显式提供这些 Qt6 组件，
    # 否则大概率会遇到登录界面白屏、只剩鼠标或者输入框出不来的情况。
    kdePackages.qtsvg
    kdePackages.qtmultimedia
    kdePackages.qtvirtualkeyboard
  ];
}
