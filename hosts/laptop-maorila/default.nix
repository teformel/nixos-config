# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./hardware-quirks.nix
      ../../modules
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  # boot.kernelPackages = pkgs.linuxPackages_latest;
  # 使用 Zen 内核以获得更低的桌面延迟和更好的游戏响应
  boot.kernelPackages = pkgs.linuxPackages_zen;
  # 使用 linuxPackagesFor 函数，将 CachyOS 最新的 v3 优化版内核包装成系统可用的完整套件
  #boot.kernelPackages = pkgs.linuxPackagesFor inputs."nix-cachyos-kernel".packages.${pkgs.system}.linux-cachyos-latest-lto-x86_64-v3;

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
        "https://attic.xuyh0120.win/lantian" # 🌟 [新增] CachyOS 内核专属的二进制缓存源
        "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store" # 清华源
        "https://mirrors.ustc.edu.cn/nix-channels/store"
        "https://mirror.sjtu.edu.cn/nix-channels/store"
        "https://cache.nixos.org/"
      ];
  
      # 这是必须的，你需要添加这些镜像源的公钥，Nix 才会信任它们下载的二进制包
      trusted-public-keys = [
        "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc=" # 🌟 [新增] 必须添加此公钥，否则不信任该缓存
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        # （注：SJTU 和 USTC 都是全量同步官方缓存，所以只要有官方的公钥就可以验证包的签名，不需要额外加它们的特定公钥）
      ];
    };

  # 允许 wheel 组的用户（也就是你）信任第三方缓存
  nix.settings.trusted-users = [ "root" "@wheel" ];

  networking.hostName = "Laptop-maorila"; # Define your hostname.

  # Configure network connections interactively with nmcli or nmtui.
  networking.networkmanager.enable = true;

  # Enable network manager applet
  #programs.nm-applet.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Shanghai";
  services.timesyncd.enable = true;
  # 启用 Chrony 守护进程
  services.chrony.enable = true;

  # 如果启用了 Chrony，同样可以使用 networking.timeServers 来指定上游服务器
  # 2. 修改 NTP 服务器为国内常见的高速源（可选，但推荐）
  networking.timeServers = [
    "ntp.aliyun.com"
    "ntp.tencent.com"
    "cn.pool.ntp.org"
  ];

  # Configure network proxy if necessary
  #networking.proxy.default = "http://127.0.0.1:7897";
  #networking.proxy.allProxy = "socks5://127.0.0.1:7897";
  #networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # 为了防止平时运行中的交换空间写入到真实的物理 Swap（拖慢速度并损耗 SSD），
  # 需要确保 ZRAM 的优先级高于物理 Swap 分区。
  # 事实上，NixOS 默认开启 ZRAM 时的优先级（100）远高于普通 Swap 分区（通常 < 0）。
  # 所以这样配置后：
  # - 平时内存不足时：优先压缩到 ZRAM。
  # - 触发休眠 (Hibernate) 时：内存数据会写入刚切出来的 /dev/nvme0n1 上的 swap 分区。
  # 开启 ZRAM
  zramSwap = {
    enable = true;
    # 默认算法是 zstd，默认占用最大内存比例是 50%。
    # 一般不需要额外配置，开箱即用的默认值就非常优秀。
  };

  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Enable CUPS to print documents.
  services.printing.enable = false;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.maorila = {
    isNormalUser = true;
    description = "maorila";
    initialPassword = "maorila";
    shell = pkgs.fish;
    # 🚨 [修改这里] 加入 libvirtd 和 kvm
    extraGroups = [ "networkmanager" "wheel" "libvirtd" "kvm" ];
  };
  users.mutableUsers = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # 🌟 启用 nh 工具 (Nix Helper)，提供更快的构建体验和自动清理
  programs.nh = {
    enable = true;
    # 🌟 开启 nh 自动清理定时任务
    clean = {
      enable = true;
      # 定时任务触发时间，采用 systemd.time 格式（这里代表每周日凌晨 5:00 自动清理）
      dates = "weekly"; 
      # 传递给 nh clean 的垃圾回收参数
      # --keep 7d 代表保留最近 7 天内的系统世代
      # --keep-since 3d 代表保留最近 3 天内构建的所有临时缓存/派生文件
      extraArgs = "--keep 7d --keep-since 3d";
    };
    # 指定系统的 Flake 源路径，这样你可以在任何地方运行 nh os switch
    flake = "/home/maorila/nixos-config"; 
  };

  # 为保证全终端兼容，顺手注入全局环境变量
  environment.variables.FLAKE = "/home/maorila/nixos-config";

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    #的大部分核心终端工具已经移至 modules/core/cli.nix
  ];
  
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
  system.stateVersion = "26.05"; # Did you read the comment?

}

