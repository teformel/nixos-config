# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  # boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "maorila-laptop"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # === 关键：配置全局代理 ===
  # 这样可以让 Nix 命令、终端、浏览器都走 Clash 的代理
  networking.proxy.default = "http://127.0.0.1:7897";
  
  # 设置不走代理的地址 (避免本地回环也走代理导致连不上)
  networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # === KDE Connect 防火墙规则 ===
  # 必须开启，否则手机搜不到电脑
  networking.firewall = {
    enable = true;
    allowedTCPPortRanges = [
      { from = 1714; to = 1764; }
    ];
    allowedUDPPortRanges = [
      { from = 1714; to = 1764; }
    ];
  };

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

  nix.settings.substituters = [ "https://mirrors.ustc.edu.cn/nix-channels/store" "https://cache.nixos.org" ];
  # nix.settings.substituters = lib.mkForce [ "https://mirrors.cernet.edu.cn/nix-channels/store" ];

  # 开启 Nix 命令和 Flakes 功能
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };
  # === 🖥️ 登录界面美化 (SDDM) ===

  # 1. 确保 Xserver 服务开启 (SDDM 依赖它)
  services.xserver.enable = true;
  programs.hyprland.enable = true;

  # 2. 配置 SDDM 显示管理器
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true; # 非常重要：让 SDDM 支持 Wayland 会话
    theme = "sddm-astronaut-theme";  # 指定我们要用的主题名字
    # theme = "where_is_my_sddm_theme";
    # 💉 关键修改：直接把依赖注入给 SDDM 服务
    # 这样它绝对能找到 QtMultimedia，不再依赖系统环境变量
    extraPackages = with pkgs; [
      kdePackages.qtmultimedia
      kdePackages.qtsvg
      kdePackages.qt5compat
      sddm-astronaut
      where-is-my-sddm-theme
    ];
  };

  # === 🔊 声音服务配置 (PipeWire) ===
  # 必须开启 rtkit 才能让音频服务获得高优先级
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true; # <--- 关键：兼容 PulseAudio，让 Chrome 能认出它
    # jack.enable = true; # 如果你搞音乐制作才需要这个
  };
  
  # === 🚀 切换到最新内核 (解决新硬件驱动问题) ===
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # === 🚑 保持固件开启 ===
  # 这个芯片必须要有 sof-firmware 才能发声，千万别删
  hardware.enableAllFirmware = true;
  hardware.firmware = [ pkgs.sof-firmware ];

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

  # === 💾 存储设备管理 ===
  services.gvfs.enable = true; # 很多文件管理器依赖它
  services.udisks2.enable = true; # 核心挂载服务

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
    hyprpaper
    qt6Packages.fcitx5-configtool
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    sarasa-gothic
    curl
    sddm-astronaut # ✨ 这里安装漂亮的主题包
    where-is-my-sddm-theme # ✨ 极简高颜值主题
    kdePackages.qtmultimedia
    kdePackages.qtsvg
    kdePackages.qt5compat
  ];

  # === Google Chrome 强制插件策略 (系统级) ===
  environment.etc."opt/chrome/policies/managed/extensions.json".text = builtins.toJSON {
    ExtensionSettings = {
      # 1. Bitwarden
      "nngceckbapebfimnlniiiahkandclblb" = {
        installation_mode = "force_installed";
        update_url = "https://clients2.google.com/service/update2/crx";
      };
      # 2. Raindrop.io
      "ldgfbffkinooeloadekpmfoklnobpien" = {
        installation_mode = "force_installed";
        update_url = "https://clients2.google.com/service/update2/crx";
      };
    };
  };

  # === 字体配置 ===
  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      sarasa-gothic
      nerd-fonts.jetbrains-mono # 确保装了这个，它是目前最好的编程字体之一
    ];

    fontconfig = {
      defaultFonts = {
        # 你的系统界面字体 (无衬线)
        sansSerif = [ "Noto Sans CJK SC" "Source Han Sans SC" ];
        
        # 你的文档字体 (衬线)
        serif = [ "Noto Serif CJK SC" "Source Han Serif SC" ];

        # === 重点修改这里：默认等宽字体 ===
        # 1. JetBrainsMono Nerd Font: 英文优先用这个，带图标，写代码极其舒服
        # 2. Sarasa Mono SC: 中文用这个，它能和英文严格 2:1 对齐
        # 3. Noto Sans Mono CJK SC: 最后的保底
        monospace = [ "JetBrainsMono Nerd Font" "Sarasa Mono SC" "Noto Sans Mono CJK SC" ];
      };
    };
  };

  # === 🎮 Steam 游戏平台 ===
  programs.steam = {
    enable = true;
    
    # 如果你想用 Steam 串流 (手机玩电脑游戏)，把这个打开
    remotePlay.openFirewall = true; 
    
    # 如果你想当服务器主机，把这个打开
    dedicatedServer.openFirewall = true;
    
    # 修复 Steam 里的中文输入法问题 (Fcitx5)
    # 这是一个比较新的选项，如果不生效也没关系，后续可以手动修
    extest.enable = true; 
  };
  
  # === 🎮 游戏模式 (可选但推荐) ===
  # 这个工具能自动优化 CPU/GPU 性能，玩游戏时更流畅
  programs.gamemode.enable = true;

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
