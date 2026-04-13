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

  # 确保 TUN 内核模块已加载
  boot.kernelModules = [ "tun" ];

  nix.settings = {
      # 你已经有的开启 Flakes 的配置，保留它
      experimental-features = [ "nix-command" "flakes" ];
  
      # 替换官方的缓存源，这里推荐按优先级排列：
      # 1. SJTU (上海交大) 的镜像，目前 NixOS 社区反馈在国内速度极其稳定
      # 2. USTC (中科大) 镜像，作为备用
      # 3. 官方缓存源，作为最后的兜底
      substituters = [
        "https://mirror.sjtu.edu.cn/nix-channels/store"
        "https://mirrors.ustc.edu.cn/nix-channels/store"
        "https://cache.nixos.org/"
      ];
  
      # 这是必须的，你需要添加这些镜像源的公钥，Nix 才会信任它们下载的二进制包
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        # （注：SJTU 和 USTC 都是全量同步官方缓存，所以只要有官方的公钥就可以验证包的签名，不需要额外加它们的特定公钥）
      ];
    };

  networking.hostName = "nixos"; # Define your hostname.

  # Configure network connections interactively with nmcli or nmtui.
  networking.networkmanager.enable = true;

  # Enable network manager applet
  #programs.nm-applet.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Shanghai";

  # Configure network proxy if necessary
  #networking.proxy.default = "http://127.0.0.1:7897";
  #networking.proxy.allProxy = "socks5://127.0.0.1:7897";
  #networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # 防火墙 (KDE Connect & TUN 模式支持)
  networking.firewall = {
    enable = true;
    
    # 🚀 [新增] 关闭反向路径过滤
    # 宽松的反向路径过滤（老生常谈的必须项）
    checkReversePath = "loose";

    allowedTCPPortRanges = [ { from = 1714; to = 1764; } ];
    allowedUDPPortRanges = [ { from = 1714; to = 1764; } ];
    # 信任 Clash 创建的虚拟网卡（根据你的配置，通常叫 Mihomo 或者 Meta）
    trustedInterfaces = [ "Mihomo" ];
    #extraReversePathFilterRules = ''iifname { "Mihomo" } accept comment "trusted interface"'';
  };

  # 1. 开启 dconf（在独立窗口管理器中，这是保存和读取图标主题必须的核心）
  programs.dconf.enable = true;
  # 🚀 [新增] 启用 Qt 模块并指定配置工具
  qt = {
    enable = true;
    # 指定使用 qt5ct/qt6ct 作为 Qt 程序的全局主题管理器
    platformTheme = "qt5ct"; 
  };

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
      # 🚀 核心魔法：重载 fcitx5-rime，把基础数据和雾凇词库同时注入进去
      (fcitx5-rime.override { rimeDataPkgs = [ rime-data rime-ice ]; })
      # 🚨 把这个恢复开启！它不仅增强输入体验，还负责很多托盘图标的渲染
      fcitx5-gtk 
          
      # (可选) 强烈建议顺手装个官方配置工具，方便以后改快捷键
      qt6Packages.fcitx5-configtool
      # 🚀 [新增] Fcitx5 专属的 Material 风格主题，自带所有 UI 图标
      fcitx5-material-color
    ];
    fcitx5.waylandFrontend = true;
  };

  # 强制全局注入 Fcitx5 环境变量，专治 i3wm 各种不服
  environment.sessionVariables = {
    GLFW_IM_MODULE = "ibus"; # 顺手解决一些游戏/图形库的输入问题
    #GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";

    NIXOS_OZONE_WL = "1";
    # 🚀 [新增] 强制全局写入 Qt 主题变量，专治 Wayland 下的环境变量丢失
    QT_QPA_PLATFORMTHEME = "qt5ct";
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
    # 🚨 [修改这里] 加入 libvirtd 和 kvm
    extraGroups = [ "networkmanager" "wheel" "libvirtd" "kvm" ];
    #hashedPassword = "$6$hnQqq.qZqnTZvLyx$3I.tDiuePXkQWDFaHfisK8ZSvwiX6jHckJM35xUcNaq7FtPhsNB5wbMcvOVxS9.Sh9/CLOddtGudDmBDrRJOY/";
  };

  # Install firefox.
  programs.firefox.enable = false;

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
    #pkgs.ungoogled-chromium
    pkgs.google-chrome
    htop
    btop
    vscode
    # 从 flake inputs 中安装 Noctalia
    inputs.noctalia.packages.${pkgs.system}.default
    
    alacritty          # Niri 默认绑定的终端
    wl-clipboard       # Wayland 剪贴板支持
    xwayland-satellite # XWayland 兼容支持
    papirus-icon-theme  # 极其强大的标准图标库
    nwg-look # 🚀 [新增] 专门用于 Wayland 的外观设置工具
    # 安装 Qt 主题设置工具（因为最新的 Fcitx5 已经全面迁移到 Qt6）
    kdePackages.qt6ct 
    libsForQt5.qt5ct  # 顺手兼容旧版的 Qt5 软件
  ];

  # 开启 ZRAM
  zramSwap = {
    enable = true;
    # 默认算法是 zstd，默认占用最大内存比例是 50%。
    # 一般不需要额外配置，开箱即用的默认值就非常优秀。
  };

  # 电源管理与休眠支持
  powerManagement.enable = true;
  # 1. 开启电源与性能管理（MateBook 电池与性能模式刚需）
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;

  # 2. 开启蓝牙服务
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

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

  # 1. Clash Verge Rev 官方推荐满血配置
  programs.clash-verge = {
    enable = true;
    tunMode = true;
    # 【致胜关键】开启后，系统会自动在底层跑服务模式，彻底解决权限报错
    serviceMode = true; 
    autoStart = true;
  };

  # === 基础服务 ===
  services.gvfs.enable = true;
  services.udisks2.enable = true;
  
  #nix.extraOptions = ''
  #  # 填入你自己的 GitHub Personal Access Token (Classic 即可，不需要勾选任何权限，只要是个有效的 Token 就行)
  #  # 格式：access-tokens = github.com=ghp_xxxxxxxxxxxxxxxxxxxx
  #  access-tokens = github.com=你的真实TOKEN
  #'';

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

  # 🚀 KVM / QEMU 满血虚拟化支持
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true; # 开启 TPM 2.0 模拟 (Win11 刚需)
      ovmf = {
        enable = true;
        packages = [ pkgs.OVMFFull.fd ]; # 支持 Secure Boot 的完整 UEFI 固件
      };
    };
  };

  # 启用 Virt-Manager 图形化管理工具
  # （使用 programs 模块启用，它会自动帮你处理 dconf 和 GTK 主题等依赖，不要只写在 systemPackages 里）
  programs.virt-manager.enable = true;

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

