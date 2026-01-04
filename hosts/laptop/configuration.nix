{ config, pkgs, ... }:

{
  imports =
    [ 
      ./hardware-configuration.nix
      
      # === 系统功能模块 ===
      ../../modules/system/gaming.nix        # 游戏优化
      ../../modules/system/apps/chrome.nix   # 浏览器模块
      ../../modules/system/audio.nix         # 音频与修复
      ../../modules/system/fonts.nix         # 字体配置
    ];

  # === 核心引导与硬件 ===
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest; # 使用最新内核

  # === 网络与代理 ===
  networking.hostName = "maorila-laptop";
  networking.networkmanager.enable = true;
  networking.proxy.default = "http://127.0.0.1:7897";
  networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  
  # 防火墙 (KDE Connect)
  networking.firewall = {
    enable = true;
    allowedTCPPortRanges = [ { from = 1714; to = 1764; } ];
    allowedUDPPortRanges = [ { from = 1714; to = 1764; } ];
  };

  # === 本地化与输入法 ===
  time.timeZone = "Asia/Shanghai";
  i18n.defaultLocale = "zh_CN.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "zh_CN.UTF-8";
    LC_IDENTIFICATION = "zh_CN.UTF-8";
    LC_MEASUREMENT = "zh_CN.UTF-8";
    LC_MONETARY = "zh_CN.UTF-8";
    LC_NAME = "zh_CN.UTF-8";
    LC_NUMERIC = "zh_CN.UTF-8";
    LC_PAPER = "zh_CN.UTF-8";
    LC_TELEPHONE = "zh_CN.UTF-8";
    LC_TIME = "zh_CN.UTF-8";
    LC_MESSAGES = "en_US.UTF-8"; 
  };

  # === Nix 核心设置 ===
  nix.settings.substituters = [
    "https://mirrors.cernet.edu.cn/nix-channels/store"
    "https://mirrors.ustc.edu.cn/nix-channels/store"
    "https://cache.nixos.org"
  ];
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  # === 图形环境 ===
  services.xserver.enable = true;
  services.xserver.xkb.layout = "us";
  programs.hyprland.enable = true;
  hardware.graphics.enable = true;

  # SDDM 登录管理器
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "sddm-astronaut-theme";
    extraPackages = with pkgs; [
      kdePackages.qtmultimedia
      kdePackages.qtsvg
      kdePackages.qt5compat
      sddm-astronaut
      where-is-my-sddm-theme
    ];
  };

  # === TTY 控制台美化 (KMSCON) ===
  services.kmscon = {
    enable = true;
    hwRender = true;
    fonts = [ { name = "Sarasa Mono SC"; package = pkgs.sarasa-gothic; } ];
    extraConfig = ''font-size=24'';
  };

  # === 用户与 Shell ===
  programs.zsh.enable = true;
  users.users.maorila = {
    isNormalUser = true;
    description = "maorila";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh;
  };

  # === 基础服务 ===
  services.gvfs.enable = true;
  services.udisks2.enable = true;

  # 系统级基础包 (最小集)
  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
    git
    sddm-astronaut
    where-is-my-sddm-theme
    kdePackages.qtmultimedia
    kdePackages.qtsvg
    kdePackages.qt5compat
  ];

  system.stateVersion = "25.11"; 
}