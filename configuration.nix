# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  networking.hostName = "nixos"; # Define your hostname.

  # Configure network connections interactively with nmcli or nmtui.
  networking.networkmanager.enable = true;

  # Enable network manager applet
  programs.nm-applet.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Shanghai";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

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
      #fcitx5-gtk                         # 增强在 GTK 程序中的输入体验
      fcitx5-rime                        # 核心组件：引入 Rime 引擎
    ];
    fcitx5.waylandFrontend = true; 
  };

  # 强制全局注入 Fcitx5 环境变量，专治 i3wm 各种不服
  environment.sessionVariables = {
    GLFW_IM_MODULE = "ibus"; # 顺手解决一些游戏/图形库的输入问题
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
  };

  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # 1. 开启 Niri 混成器
  programs.niri.enable = true;

  # 2. 显示管理器
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  # Enable the X11 windowing system.
  #services.xserver = {
    #enable = true;

    # 1. 开启 LXQt (轻量级桌面环境)
    #desktopManager.lxqt.enable = true;

    # 2. 开启 i3wm (平铺式窗口管理器 - 极客首选)
    #windowManager.i3 = {
    #  enable = true;
    #  extraPackages = with pkgs; [
    #    dmenu 
    #    i3status
    #  ];
    #};

    # 3. 开启 IceWM (复古极轻量窗口管理器)
    #windowManager.icewm.enable = true;

    # 建议使用 LightDM 作为登录界面，它对多环境切换支持很好
    #displayManager.lightdm.enable = true;
  #};
  

  # Configure keymap in X11
  #services.xserver.xkb = {
  #  layout = "cn";
  #  variant = "";
  #};

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    wqy_microhei
    wqy_zenhei
    nerd-fonts.fira-code  # 最受程序员欢迎的连字代码字体 FiraCode 的 Nerd 版
    nerd-fonts.meslo-lg   # 另一个非常好看的终端字体
  ];

  # Enable CUPS to print documents.
  services.printing.enable = true;
  
  # (确保 rtkit 依然开启)
  security.rtkit.enable = true;

  # Enable sound.
  # services.pulseaudio.enable = true;
  # OR
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # === 🚑 固件支持 ===
  hardware.enableAllFirmware = true;
  hardware.firmware = [ pkgs.sof-firmware ];

  # === 🔊 声明式音频修复 (Sof-Essx8336) ===
  # 这种声卡默认会把 DAC 通道静音，这里我们强制在开机时打开它
  systemd.services.fix-sof-sound = {
    description = "Unmute sof-essx8336 channels on boot";
    after = [ "sound.target" "pipewire.service" ]; 
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
    script = ''
      CARD="sofessx8336"
      ${pkgs.alsa-utils}/bin/amixer -c $CARD sset 'Left Headphone Mixer Left DAC' on
      ${pkgs.alsa-utils}/bin/amixer -c $CARD sset 'Right Headphone Mixer Right DAC' on
      ${pkgs.alsa-utils}/bin/amixer -c $CARD sset 'Speaker' on
      ${pkgs.alsa-utils}/bin/amixer -c $CARD sset 'Headphone' on
      ${pkgs.alsa-utils}/bin/amixer -c $CARD sset 'DAC' 100% || true
    '';
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

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

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
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
    # 从 flake inputs 中安装 Noctalia
    inputs.noctalia.packages.${pkgs.system}.default
    
    kitty              # Niri 默认绑定的终端
    wl-clipboard       # Wayland 剪贴板支持
    xwayland-satellite # XWayland 兼容支持

  ];

  # 开启 ZRAM
  zramSwap = {
    enable = true;
    # 默认算法是 zstd，默认占用最大内存比例是 50%。
    # 一般不需要额外配置，开箱即用的默认值就非常优秀。
  };

  # 电源管理与休眠支持
  powerManagement.enable = true;

  # 为了防止平时运行中的交换空间写入到真实的物理 Swap（拖慢速度并损耗 SSD），
  # 需要确保 ZRAM 的优先级高于物理 Swap 分区。
  # 事实上，NixOS 默认开启 ZRAM 时的优先级（100）远高于普通 Swap 分区（通常 < 0）。
  # 所以这样配置后：
  # - 平时内存不足时：优先压缩到 ZRAM。
  # - 触发休眠 (Hibernate) 时：内存数据会写入刚切出来的 /dev/nvme0n1 上的 swap 分区。

  # 可选：如果希望合上笔记本盖子时直接休眠（Suspend to disk）而不是睡眠（Suspend to RAM）
  # services.logind.lidSwitch = "hibernate"; 

  # 5. Shell 环境支持
  # 确保 Fish Shell 在 Wayland 桌面下环境变量正常加载
  programs.bash.enable = true;

  # 6. XDG 门户机制 (对于屏幕共享和文件选择框是刚需)
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [ 
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome 
    ];
  };

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

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.11"; # Did you read the comment?

}

