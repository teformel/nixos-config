# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      <home-manager/nixos>
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "maorila-laptop"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Shanghai";

  # 设置系统默认语言为中文 (UTF-8)
  i18n.defaultLocale = "zh_CN.UTF-8";

  i18n.extraLocaleSettings = {
    # 把各种格式（时间、货币、度量衡等）都设为中文
    LC_ADDRESS = "zh_CN.UTF-8";
    LC_IDENTIFICATION = "zh_CN.UTF-8";
    LC_MEASUREMENT = "zh_CN.UTF-8";
    LC_MONETARY = "zh_CN.UTF-8";
    LC_NAME = "zh_CN.UTF-8";
    LC_NUMERIC = "zh_CN.UTF-8";
    LC_PAPER = "zh_CN.UTF-8";
    LC_TELEPHONE = "zh_CN.UTF-8";
    LC_TIME = "zh_CN.UTF-8";
    
    # 【推荐保留】让终端报错保持英文，防止 TTY 乱码
    # 如果你不在乎 TTY 乱码，想让系统完全变中文，可以把下面这行删掉
    LC_MESSAGES = "en_US.UTF-8"; 
  };

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [
      qt6Packages.fcitx5-chinese-addons
      fcitx5-gtk
      fcitx5-rime
    ];
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # === 启用 KMSCON (支持中文的高清 TTY) ===
  services.kmscon = {
    enable = true;
    hwRender = true; # 尝试使用显卡加速 (如果花屏就改成 false)
    
    # 配置字体：使用我们之前装好的更纱黑体
    fonts = [
      {
        name = "Sarasa Mono SC";
        package = pkgs.sarasa-gothic;
      }
    ];

    # 额外配置：设置字号 (根据你的屏幕分辨率调整，2K/4K屏建议设大点)
    extraConfig = ''
      font-size=24
    '';
    
    # 自动登录 (可选：如果你不想每次在 TTY 输密码，仅限调试用)
    # autologinUser = "maorila";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.maorila = {
    isNormalUser = true;
    description = "maorila";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
  };

  programs.hyprland.enable = true;
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    git
    kitty
    wofi
    waybar
    dunst
    kdePackages.dolphin
    pkgs.google-chrome
    hyprpaper
    qt6Packages.fcitx5-configtool
    git
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    sarasa-gothic
  ];

  # === 字体配置 ===
  fonts = {
    # 安装字体包
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans   # 关键：思源黑体 (用于屏幕显示)
      noto-fonts-cjk-serif  # 关键：思源宋体 (用于排版)
      noto-fonts-color-emoji      # 彩色 Emoji
      sarasa-gothic         # 更纱黑体 (你之前装的)
      source-han-sans
      source-han-serif
    ];

    # 关键：配置默认字体 (防止 Chrome 抽风去用日文字体)
    fontconfig = {
      defaultFonts = {
        serif = [ "Noto Serif CJK SC" "Source Han Serif SC" ];
        sansSerif = [ "Noto Sans CJK SC" "Source Han Sans SC" ];
        monospace = [ "Sarasa Mono SC" ];
      };
    };
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  hardware.graphics.enable = true;

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  nix.settings.substituters = [ "https://mirrors.ustc.edu.cn/nix-channels/store" "https://cache.nixos.org" ];
  # nix.settings.substituters = lib.mkForce [ "https://mirrors.cernet.edu.cn/nix-channels/store" ];

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  home-manager.users.maorila = import ./home.nix;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

}
