{ config, lib, pkgs, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./hardware-quirks.nix
      ../../modules
    ];

  # ==============================
  # 核心系统大一统配置 (Core System)
  # ==============================

  # --- 1. 引导与内核 ---
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_zen;
  boot.kernelModules = [ "tun" ];

  # --- 2. 主机名与版本 ---
  networking.hostName = "Laptop-maorila";
  system.stateVersion = "26.05";

  # --- 3. 网络与时间 ---
  networking.networkmanager.enable = true;
  time.timeZone = "Asia/Shanghai";
  services.timesyncd.enable = true;
  services.chrony.enable = true;
  networking.timeServers = [
    "ntp.aliyun.com"
    "ntp.tencent.com"
    "cn.pool.ntp.org"
  ];

  # --- 4. Nix 与源镜像 ---
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    substituters = [
      "https://attic.xuyh0120.win/lantian"
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://mirror.sjtu.edu.cn/nix-channels/store"
      "https://cache.nixos.org/"
    ];
    trusted-public-keys = [
      "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
    trusted-users = [ "root" "@wheel" ];
  };
  nixpkgs.config.allowUnfree = true;

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.dates = "weekly"; 
    clean.extraArgs = "--keep 7d --keep-since 3d";
    flake = "/home/maorila/nixos-config"; 
  };
  environment.variables.FLAKE = "/home/maorila/nixos-config";

  # --- 5. 用户账户 ---
  users.users.maorila = {
    isNormalUser = true;
    description = "maorila";
    initialPassword = "maorila";
    shell = pkgs.fish;
    extraGroups = [ "networkmanager" "wheel" "libvirtd" "kvm" ];
  };
  users.mutableUsers = true;

  # --- 6. 性能优化 ---
  zramSwap.enable = true;

  # --- 7. 系统语言与中文输入法 (Fcitx5) ---
  i18n.defaultLocale = "zh_CN.UTF-8";
  i18n.supportedLocales = [ "zh_CN.UTF-8/UTF-8" "en_US.UTF-8/UTF-8" ];
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
    LC_MESSAGES = "zh_CN.UTF-8";
  };

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [
      (fcitx5-rime.override { rimeDataPkgs = [ rime-data rime-ice ]; })
      fcitx5-gtk 
      qt6Packages.fcitx5-configtool
      fcitx5-material-color
    ];
    fcitx5.waylandFrontend = true;
  };

  environment.sessionVariables = {
    GLFW_IM_MODULE = "ibus";
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
    NIXOS_OZONE_WL = "1";
    LANG = "zh_CN.UTF-8";
    LC_ALL = "zh_CN.UTF-8";
  };
}
