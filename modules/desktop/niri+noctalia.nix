# modules/desktop.nix
{ config, pkgs, inputs, ... }:

{
  # KDE Connect 防火墙规则
  networking.firewall.allowedTCPPortRanges = [ { from = 1714; to = 1764; } ];
  networking.firewall.allowedUDPPortRanges = [ { from = 1714; to = 1764; } ];

  # === 桌面环境与显示管理器 ===
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "catppuccin-mocha-mauve"; 
    
    # 🌟 1. 显式告诉 SDDM 使用哪个鼠标指针主题
    settings = {
      Theme = {
        # 这里的名字必须和光标主题文件夹的名字完全对应
        CursorTheme = "catppuccin-mocha-mauve-cursors"; 
      };
    };
    
    extraPackages = with pkgs; [
      kdePackages.qtsvg
      kdePackages.qtmultimedia
      kdePackages.qtvirtualkeyboard
      kdePackages.qt5compat
      
      # 🌟 2. 补上 Qt6 的 Wayland 支持模块，确保输入设备在 Wayland 下正确渲染
      kdePackages.qtwayland 
    ];
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

  # 🌟 新增：声明全局默认终端
  environment.variables = {
    TERMINAL = "ghostty";
    # 顺手加上这个，能让很多终端应用（比如 bottom）的色彩显示更正常
    COLORTERM = "truecolor"; 
  };

  # === 系统包 ===
  environment.systemPackages = with pkgs; [
    glib                       
    gsettings-desktop-schemas  
    inputs.noctalia.packages.${pkgs.system}.default    
    wl-clipboard       
    xwayland-satellite 
    papirus-icon-theme 
    
    # 🌟 恢复 nwg-look！脱离了 GNOME Tweaks，你需要它来修改 GTK 主题、图标和鼠标指针
    nwg-look           
    
    kdePackages.qt6ct 
    libsForQt5.qt5ct  
    
    catppuccin-sddm
    # 🌟 3. 安装与你主题配套的 Catppuccin 鼠标包，提供实体的光标文件
    catppuccin-cursors.mochaMauve
  ];

  # 【用户层配置】
  home-manager.users.maorila = {
    home.packages = with pkgs; [
      ghostty
      file-roller   
      vscode
      google-chrome
      mission-center
      localsend
      mark-shot     # 强力的 Wayland 原生截图与长截图工具
    ];

    services.udiskie = {
      enable = true;
      tray = "always";
    };
  };
}
