# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  virtualisation.vmware.guest.enable = true;

   # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # 开启 SSH 服务，打通物理机与虚拟机的任督二脉
  services.openssh = {
    enable = true;
    settings = {
      # 允许密码登录（因为我们还没配密钥）
      PasswordAuthentication = true;
      # 拒绝 root 用户直接登录（安全好习惯）
      PermitRootLogin = "no";
    };
  };

  # Enable network manager applet
  programs.nm-applet.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Shanghai";

  # Select internationalisation properties.
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
  };

  # 系统语言与中文输入法支持 (Fcitx5)
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [
      #qt6Packages.fcitx5-chinese-addons  # 官方中文拼音引擎
      fcitx5-gtk                         # 增强在 GTK 程序中的输入体验
      fcitx5-rime                        # 核心组件：引入 Rime 引擎
    ];
  };

  # 强制全局注入 Fcitx5 环境变量，专治 i3wm 各种不服
  environment.sessionVariables = {
    GLFW_IM_MODULE = "ibus"; # 顺手解决一些游戏/图形库的输入问题
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
  };

  services.xserver = {
    enable = true;

    # 1. 开启 LXQt (轻量级桌面环境)
    desktopManager.lxqt.enable = true;

    # 2. 开启 i3wm (平铺式窗口管理器 - 极客首选)
    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        dmenu 
        i3status
      ];
    };

    # 3. 开启 IceWM (复古极轻量窗口管理器)
    windowManager.icewm.enable = true;

    # 建议使用 LightDM 作为登录界面，它对多环境切换支持很好
    displayManager.lightdm.enable = true;
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "cn";
    variant = "";
  };

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    wqy_microhei
    wqy_zenhei
    nerd-fonts.fira-code  # 最受程序员欢迎的连字代码字体 FiraCode 的 Nerd 版
    nerd-fonts.meslo-lg      # 另一个非常好看的终端字体
  ];


  # Enable CUPS to print documents.
  services.printing.enable = true;

  # 1. 极其关键：强制关闭 PipeWire，干掉桌面环境的默认设置
  services.pipewire.enable = false;
# 2. 开启老兵 PulseAudio (使用新版语法)
  services.pulseaudio.enable = true;
  services.pulseaudio.support32Bit = true;
# (确保 rtkit 依然开启)
  security.rtkit.enable = true;
  #services.pipewire = {
  #  enable = true;
  #  alsa.enable = true;
  #  alsa.support32Bit = true;
  #  pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  #};
  
  # 禁用 xserver 默认强塞的 Xterm 终端
  services.xserver.desktopManager.xterm.enable = false;
  # 彻底将 xterm 软件包从 X11 的默认捆绑安装列表中踢出！
  services.xserver.excludePackages = [ pkgs.xterm ];

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.maorila = {
    isNormalUser = true;
    description = "maorila";
    extraGroups = [ "networkmanager" "wheel" ];
    #hashedPassword = "$6$hnQqq.qZqnTZvLyx$3I.tDiuePXkQWDFaHfisK8ZSvwiX6jHckJM35xUcNaq7FtPhsNB5wbMcvOVxS9.Sh9/CLOddtGudDmBDrRJOY/";
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    neovim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    curl
    micro
    eza
    git
    pkgs.ungoogled-chromium
    htop
    btop
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

}
