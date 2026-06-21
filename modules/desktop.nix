# modules/desktop/gnome.nix
{ config, pkgs, lib, inputs, ... }:

{
  # KDE Connect 防火墙规则
  networking.firewall.allowedTCPPortRanges = [ { from = 1714; to = 1764; } ];
  networking.firewall.allowedUDPPortRanges = [ { from = 1714; to = 1764; } ];

  # === 桌面环境与显示管理器 ===
  # 启用 X11 基础服务
  services.xserver.enable = true;

  # 🌟 修复警告：使用新版独立路径
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;


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
  programs.dconf.enable = true;

  qt = {
    enable = true;
    platformTheme = "gnome"; 
    style = "adwaita";
  };

  programs.firefox.enable = false;

  # === 基础服务 ===
  # GNOME 极度依赖 gvfs 和 udisks2，必须保留
  services.gvfs.enable = true;
  services.udisks2.enable = true;

  # 声明全局默认终端
  environment.variables = {
    TERMINAL = "ghostty";
    COLORTERM = "truecolor"; 
  };

  # === 系统包 ===
  environment.systemPackages = with pkgs; [
    glib                       
    gsettings-desktop-schemas  
    wl-clipboard       
    papirus-icon-theme 

    # 替换了 nwg-look，GNOME 环境下使用 Tweaks 即可管理主题和字体
    gnome-tweaks
  ];

  # 排除部分不需要的 GNOME 自带软件（可选，按需保留）
  environment.gnome.excludePackages = with pkgs; [
    geary # 邮件客户端
    gnome-tour
  ];

  # 【用户层配置】
  home-manager.users.maorila = {
    home.packages = with pkgs; [
      # GNOME 带有强大的原生截图工具 (直接按 Print Screen 即可唤出交互式选框)，不再需要额外的 Wayland 截图包
    ];

    services.udiskie = {
      enable = true;
      tray = "always";
    };
  };
}

